/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "TestBedViewControllerSuper.h"

void showAlert(id formatstring,...)
{
	if (!formatstring) return;
    
	va_list arglist;
	va_start(arglist, formatstring);
    id outstring = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
	
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:outstring message:nil delegate:nil cancelButtonTitle:@"Okay"otherButtonTitles:nil];
	[alertView show];
}


@implementation TestBedViewControllerSuper

#pragma mark Gameplay

- (void) startMatchWithOpponentID:(NSString *)opponentID
{
    [GKPlayer loadPlayersForIdentifiers:[NSArray arrayWithObject:opponentID] withCompletionHandler:^(NSArray *players, NSError *error)
     {
         [self activateGameGUI];
         
         if (error) return;
         opponent = [players lastObject];
         // showAlert(@"Commencing Match with %@", opponent.alias);
     }];
    
}

- (NSString *) opponentName
{
    return opponent.alias ? : @"Your opponent";
}

- (void)match:(GKMatch *) aMatch didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    
}

#pragma mark - GUI
- (void) cleanupGUI
{
    // Please implement in subclass
}

- (void) activateGameGUI
{
    // Please implement in subclass
}

#pragma mark - Match Connections

- (void)match:(GKMatch *) aMatch connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error
{
    NSLog(@"Connection failed with player %@: %@", playerID, error.localizedFailureReason);
    [self cleanupGUI];
}

- (void)match:(GKMatch *) aMatch didFailWithError:(NSError *)error
{
    [self cleanupGUI];
    showAlert(@"Lost Game Center connection");
}

- (void)match:(GKMatch *) aMatch player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state
{
    if (state == GKPlayerStateDisconnected)
    {
        NSLog(@"Player %@ disconnected", playerID);
        [match disconnect];
        [self cleanupGUI];
    }
    else if (state == GKPlayerStateConnected)
    {
        NSLog(@"Player %@ has connected", playerID);

        // Ready to go?
        if (!matchStarted && !match.expectedPlayerCount)
            [self startMatchWithOpponentID:playerID];
    }
    else
    {
        NSLog(@"Player state changed to unknown");
    }
}

// If you want disconnected matches to try to re-connect
/* - (BOOL)match:(GKMatch *) aMatch shouldReinvitePlayer:(NSString *)playerID
 {
 return YES;
 } */

#pragma mark - Matchmaking

- (void) matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)aMatch
{
    // Already playing. Ignore.
    if (matchStarted)
        return;
    
    if (viewController)
    {
        NSLog(@"Match found");
        [self dismissModalViewControllerAnimated:YES];
        match = aMatch;
        match.delegate = self;
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    // Normal matches now wait for player connection 
    
    // Invited connections may be ready to go now. If so, begin
    if (!matchStarted && !match.expectedPlayerCount)
    {
        // 2-player game.
        NSString *playerID = [match.playerIDs lastObject];
        [self startMatchWithOpponentID:playerID];
    }


    if (!matchStarted && !match.expectedPlayerCount)
    {

        NSString *playerID = [match.playerIDs lastObject];
        [GKPlayer loadPlayersForIdentifiers:[NSArray arrayWithObject:playerID] withCompletionHandler:^(NSArray *players, NSError *error)
         {
             [self activateGameGUI];
             
             if (error) return;
             opponent = [players lastObject];
             // showAlert(@"Commencing Match with %@", opponent.alias);
         }];
    }
}

- (void) matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void) matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
    showAlert(@"Error creating match: %@", error.localizedFailureReason);
}

#pragma mark - Start/Stop Games

- (void) finishMatch
{
    [match disconnect];
    [self cleanupGUI];
}

- (void) startMatch
{
    // This is not a hosted match, which allows up to 16 players
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2; // Between 2 and 4
    request.maxPlayers = 2; // Betseen 2 and 4
    
    GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
    mmvc.matchmakerDelegate = self;
    mmvc.hosted = NO;
    
    [self presentModalViewController:mmvc animated:YES];
}

- (void) addInvitationHandler
{
    [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *invitation, NSArray *playersToInvite) 
    {
        // Clean up any in-progress game
        [self finishMatch];
        NSLog(@"Invitation: %@, playersToInvite: %@", invitation, playersToInvite);
        
        if (invitation)
        {
            GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithInvite:invitation];
            mmvc.matchmakerDelegate = self;
            [self presentModalViewController:mmvc animated:YES];
        }
        else if (playersToInvite)
        {
            GKMatchRequest *request = [[GKMatchRequest alloc] init];
            request.minPlayers = 2;
            request.maxPlayers = 2; // 2-player matches for this example
            request.playersToInvite = playersToInvite;
            GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
            mmvc.matchmakerDelegate = self;
            [self presentModalViewController:mmvc animated:YES];
        }
    };
}

@end

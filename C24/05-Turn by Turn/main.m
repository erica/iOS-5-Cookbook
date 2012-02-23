/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


/*
 
 PLEASE NOTE: I am really not happy with this sample, but time limits prevented me from
 working on it any further. Only test on devices, not in Simulator.
 
 */

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "Utility.h"
#import "ModalAlertDelegate.h"

@interface TestBedViewController : UIViewController <GKTurnBasedMatchmakerViewControllerDelegate, GKTurnBasedEventHandlerDelegate>
{
    GKLocalPlayer *player;
    GKTurnBasedMatch *match;
    
    NSArray *group;    
    UITextView *textView;
    
    NSMutableArray *matches;
    NSMutableDictionary *matchDataDictionary;
}
@end

@implementation TestBedViewController

#pragma mark - Erik Dahlman Utilities

// The following methods are specifically excluded from the Cookbook license
// They belong to Erik Dahlman

// Courtesy of Erik Dahlman
+ (BOOL) isGameCenterAvailable
{
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

// Courtesy of Erik Dahlman
-(void)loadMatch: (GKTurnBasedMatch *)aMatch
{
    if (!matchDataDictionary)
        matchDataDictionary = [NSMutableDictionary dictionary];
    
    NSLog(@"matchID: %@", aMatch.matchID);
    [match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error) {
        if (error)
            NSLog(@"There was an error loading match data for matchID: %@, %@", match.matchID, error.localizedFailureReason);
        else
        {
            if (matchData == nil)
            {
                NSLog(@"%@: there was an error loading match data, it is nil", match.matchID);
                return ;
            }
            
            if (matchData.length > 0)
                NSLog(@"%@: there is some match data in here...", match.matchID);
            else
            {
                NSLog(@"%@: the match data is zero, so this match has just begun", match.matchID);
                return; // Get out of here before we put zero matchData in the dictionary
            }
            
            @synchronized(self)
            {
                [matchDataDictionary setObject: matchData forKey: aMatch.matchID];
            }
        }
    }];
    
}

// Courtesy of Erik Dahlman
-(void)loadMatches
{
    NSLog(@"loading matches...");
    
    if (!matches)
        matches = [NSMutableArray array];
    
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *handlerMatches, NSError *error) {
        if (error)
            NSLog(@"There was an error loading matches: %@", error.localizedFailureReason);
        else
        {            
            for (GKTurnBasedMatch *aMatch in handlerMatches)
            {
                [matches addObject: aMatch];
                [self loadMatch: aMatch];
            }
        }
    }];
}

// Courtesy of Erik Dahlman
-(void)addMatchData: (NSData *)matchData forMatch: (NSString *)matchID
{
    if (!matchDataDictionary)
        matchDataDictionary = [NSMutableDictionary dictionary];
    [matchDataDictionary setObject: matchData forKey: matchID];
}

// Courtesy of Erik Dahlman
-(NSData *)matchDataWithMatchID: (NSString *)matchID
{
    if (!matchDataDictionary)
        matchDataDictionary = [NSMutableDictionary dictionary];
    return [matchDataDictionary objectForKey: matchID];
}


#pragma mark GUI
- (void) initInterfaceForMatch
{
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Match", @selector(startMatch));
    self.navigationItem.leftBarButtonItem = BARBUTTON(@"ForceQuit", @selector(quitAllMatches));
    self.title = nil;
    textView.text = nil;
}

#pragma mark Game Utility
- (GKMatchRequest *) matchRequest
{
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2; // Between 2 and 4
    request.maxPlayers = 2; // Betseen 2 and 4
    return request;
}

- (BOOL) isCurrentParticipant
{
    return [match.currentParticipant.playerID isEqualToString:player.playerID];
}

- (NSUInteger) countParticipants
{
    NSUInteger count = 0;
    for (GKTurnBasedParticipant *participant in match.participants)
    {
        if (participant.status == GKTurnBasedParticipantStatusActive)
            count++;
    }
    
    return count;
}

- (void) showParticipants
{
    if (!match) return;
    
    if (group && (group.count == match.participants.count))
    {
        for (GKPlayer *eachPlayer in group)
            NSLog(@"Player: %@ [%@]", eachPlayer.alias, eachPlayer.playerID);
    }
    else
    {
        NSMutableArray *participants = [NSMutableArray array];
        for (GKTurnBasedParticipant *participant in match.participants)
        {
            if (participant.playerID)
                [participants addObject:participant.playerID];
            else
            {
                // inactive status
            }
        }
        
        [GKPlayer loadPlayersForIdentifiers:participants withCompletionHandler:^(NSArray *players, NSError *error)
         {
             if (error) return;
             group = players;
             
             for (GKPlayer *eachPlayer in group)
                 NSLog(@"Player: %@ [%@]", eachPlayer.alias, eachPlayer.playerID);
         }];
    }
}

- (GKTurnBasedParticipant *) nextParticipantTake2
{
    NSUInteger current = [match.participants indexOfObject:match.currentParticipant];
    NSUInteger count = match.participants.count;
    NSUInteger nextIndex = (current + 1) % count;
    
    for (int i = 0; i <= count; i++)
    {
        GKTurnBasedParticipant *participant = [match.participants objectAtIndex:nextIndex];
        if (participant.status == GKTurnBasedParticipantStatusActive)
            return participant;
        nextIndex = (nextIndex + 1) % count;
    }
    
    NSLog(@"Unable to find an active next participant");
    return nil;
}

- (GKTurnBasedParticipant *) nextParticipant
{
    NSUInteger current = [match.participants indexOfObject:match.currentParticipant];
    NSUInteger count = match.participants.count;
    NSUInteger nextIndex = (current + 1) % count;
    GKTurnBasedParticipant *participant = [match.participants objectAtIndex:nextIndex];
    return participant;
}

#pragma mark Game Play
- (void) myTurn
{
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    self.title = @"Loading Match Data";
    
    [match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error) {
        NSString *theText = [[NSString alloc] initWithData:match.matchData encoding:NSUTF8StringEncoding];
        textView.text = theText;
        self.navigationItem.rightBarButtonItem = BARBUTTON(@"Take turn", @selector(play));
        self.navigationItem.leftBarButtonItem = BARBUTTON(@"Quit", @selector(quitMatch));
        self.title = nil;
    }];
}

- (void) notMyTurn
{
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    self.title = @"Opponent's Turn";
    
    [match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error) {
        NSString *theText = [[NSString alloc] initWithData:match.matchData encoding:NSUTF8StringEncoding];
        textView.text = theText;
    }];
}

- (NSString *) requestString
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter a string" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    ModalAlertDelegate *delegate = [ModalAlertDelegate delegateWithAlert:alert];
    
    int response = [delegate show];
    if (!response) return nil;
    
    NSString *answer = [alert textFieldAtIndex:0].text;
    if (!answer.length) return nil;
    
    return answer;
}

- (void) play
{
    GKTurnBasedParticipant *participant = [self nextParticipant];
    if ([participant.playerID isEqualToString:player.playerID])
    {
        NSLog(@"No one else...");
        showAlert(@"No one to play with yet");
        return;
    }

    NSString *answer = [self requestString];
    if (!answer) return;
    
    NSString *theText = [[NSString alloc] initWithData:match.matchData encoding:NSUTF8StringEncoding];
    NSString *updated = [theText stringByAppendingFormat:@" %@", answer];
    if (theText.length == 0)
        updated = answer;
    textView.text = updated;
    
    
    [match endTurnWithNextParticipant:participant matchData:[updated dataUsingEncoding:NSUTF8StringEncoding] completionHandler:^(NSError *error)
     {
         if (error)
         {
             NSLog(@"Error completing turn: %@", error.localizedFailureReason);
             showAlert(@"Error completing turn: %@", error.localizedFailureReason);
         }
         else
             [self notMyTurn];
     }];
}

#pragma mark - Event callbacks
- (void)handleInviteFromGameCenter:(NSArray *)playersToInvite
{
    NSLog(@"Handle invitation");
    
    GKMatchRequest *request = [self matchRequest];
    request.playersToInvite = playersToInvite;
    GKTurnBasedMatchmakerViewController *viewController = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    viewController.showExistingMatches = NO;
    viewController.turnBasedMatchmakerDelegate = self;
    [self presentModalViewController:viewController animated:YES];
}

- (void)handleMatchEnded:(GKTurnBasedMatch *)aMatch
{
    NSLog(@"Match has ended");
    if ([match.matchID isEqualToString:aMatch.matchID])
    {
        [self initInterfaceForMatch];
        self.title = @"Match ended";
        match = nil;
    }
}

- (void)handleTurnEventForMatch:(GKTurnBasedMatch *)aMatch
{
    NSLog(@"Turn event!");

    if ([match.matchID isEqualToString:aMatch.matchID])
    {
        match = aMatch;
        [self myTurn];
    }
}

#pragma mark - Game Center Utility

- (void) removeMatch: (GKTurnBasedMatch *) aMatch
{
    [aMatch removeWithCompletionHandler:^(NSError * error)
     {
        if (error)
            NSLog(@"Error removing match: %@", error.localizedFailureReason);
     }];
}

- (void) quitAllMatches
{
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error)
     {
         if (error)
         {
             NSLog(@"Error loading matches: %@", error.localizedFailureReason);
         }
         else
         {
             NSLog(@"You were involved in %d matches", matches.count);
             for (GKTurnBasedMatch *aMatch in matches)
             {
                 [aMatch removeWithCompletionHandler:^(NSError *error)
                  {
                      if (error)
                          NSLog(@"Could not quit from %@: %@", aMatch.matchID, error.localizedFailureReason);
                      else
                          NSLog(@"Killed match %@", aMatch.matchID); 
                  }];
             }
             
             self.title = nil;
             [self initInterfaceForMatch];
             showAlert(@"You quit out of %d matches", matches.count);
         }
     }];
}

#pragma mark - User Quitting 

// This works very poorly in the current beta. Beware.
- (void) quitMatch
{
    if (![self isCurrentParticipant])
    {
        NSLog(@"You cannot quit. You are not the current participant.");
        return;
    }

    // Orderly match quit
    [match endMatchInTurnWithMatchData:match.matchData completionHandler:^(NSError *error)
     {
         if (error)
         {
             NSLog(@"Error while quitting match: %@", error.localizedFailureReason);
             self.title = @"Could not end match";
             // return;
         }

         [self initInterfaceForMatch];
     }];    
}

#pragma mark - Matchmaking
// User selected match
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)aMatch
{
    NSLog(@"Did find match");
    match = aMatch;
    
    if (viewController)
        [self dismissModalViewControllerAnimated:YES];
    
    [GKTurnBasedEventHandler sharedTurnBasedEventHandler].delegate = self;
    
    NSString *currentPlayerID = match.currentParticipant.playerID;
    if (currentPlayerID && [currentPlayerID isEqualToString:player.playerID])
    {
        [self myTurn];
    }
    else
    {
        self.title = @"Waiting";
    }
    
    [self showParticipants];
}

// Handle Quit/Forfeit
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)aMatch
{
    NSLog(@"Handle match quit");
    [match participantQuitInTurnWithOutcome:GKTurnBasedMatchOutcomeQuit 
                            nextParticipant:[self nextParticipant] 
                                  matchData:match.matchData 
                          completionHandler:^(NSError *error)
     {
         if (error)
             NSLog(@"Error while quitting match: %@", error.localizedFailureReason); 
     }];
}

// Game Center Fail
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
    showAlert(@"Error creating match: %@", error.localizedFailureReason);
    [self initInterfaceForMatch];
}

// User cancel
- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController
{
    [self dismissModalViewControllerAnimated:YES];
    [self initInterfaceForMatch];
}

- (void) startMatch
{
    GKMatchRequest *request = [self matchRequest];
    
    GKTurnBasedMatchmakerViewController *viewController = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    viewController.turnBasedMatchmakerDelegate = self;
    viewController.showExistingMatches = YES;

    self.navigationItem.rightBarButtonItem = nil;   
    [self presentModalViewController:viewController animated:YES];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    player = [GKLocalPlayer localPlayer];
    if (player && !player.authenticated)
    {
        [player authenticateWithCompletionHandler:^(NSError *error){
            if (error)
            {
                NSLog(@"Error authenticating: %@", error.localizedFailureReason);
                return;
            }
            
            // authenticated.
            [self initInterfaceForMatch];
            [GKTurnBasedEventHandler sharedTurnBasedEventHandler].delegate = self;
        }];
    }    
}

- (void) viewDidAppear:(BOOL)animated
{
    if (!textView)
    {
        textView = [[UITextView alloc] initWithFrame:CGRectZero];
        textView.editable = NO;
        textView.font = [UIFont fontWithName:@"Futura" size:IS_IPAD ? 32.0f : 16.0f];
        [self.view addSubview:textView];
    }
    
    textView.frame = self.view.bounds;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self viewDidAppear:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
}
@end
@implementation TestBedAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    // [application setStatusBarHidden:YES];
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
    window.rootViewController = nav;
	[window makeKeyAndVisible];
    return YES;
}
@end
int main(int argc, char *argv[]) {
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
        return retVal;
    }
}
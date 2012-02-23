/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "ModalAlertDelegate.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define SYSBARBUTTON(ITEM, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR] 

#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define GKBEGINNER   @"com.sadun.cookbook.beginner"

@interface TestBedViewController : UIViewController <UINavigationControllerDelegate, GKMatchDelegate, GKMatchmakerViewControllerDelegate, UITextViewDelegate>
{
    GKLocalPlayer *player;
    GKPlayer *opponent;
    GKMatch *match;
    BOOL matchStarted;
    
    UITextView *sendingView;
    UITextView *receivingView;
    UIToolbar *tb;
}
@end

@implementation TestBedViewController

#pragma mark - GUI
- (void) activateGameGUI
{
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Quit", @selector(finishMatch));
    
    sendingView.text = @"";
    sendingView.editable = YES;
    sendingView.delegate = self;
    [sendingView becomeFirstResponder];
    
    receivingView.text = @"";

    matchStarted = YES;
}

- (void) cleanupGUI
{
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Match", @selector(startMatch));
    sendingView.editable = NO;
    sendingView.delegate = nil;
    
    matchStarted = NO;
    match = nil;
}

#pragma mark - Typing gameplay

- (void)textViewDidChange:(UITextView *)textView
{
    NSError *error;
    NSData *dataToSend = [sendingView.text dataUsingEncoding:NSUTF8StringEncoding];
    BOOL success = [match sendDataToAllPlayers:dataToSend withDataMode:GKMatchSendDataReliable error:&error];
    if (!success)
        NSLog(@"Error sending match data: %@", error.localizedFailureReason);
}

- (void)match:(GKMatch *) aMatch didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    NSString *received = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    receivingView.text = received;
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost Game Center connection" message:error.localizedFailureReason delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
    [alert show];
    
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

        if (!matchStarted && !match.expectedPlayerCount)
        {
            [GKPlayer loadPlayersForIdentifiers:[NSArray arrayWithObject:playerID] withCompletionHandler:^(NSArray *players, NSError *error)
             {
                 [self activateGameGUI];
                 
                 if (error) return;
                 opponent = [players lastObject];
                 NSString *matchString = [NSString stringWithFormat:@"Commencing Match with %@", opponent.alias];
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:matchString message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
                 [alert show];
             }];
        }
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
        [GKPlayer loadPlayersForIdentifiers:[NSArray arrayWithObject:playerID] withCompletionHandler:^(NSArray *players, NSError *error)
         {
             [self activateGameGUI];
             
             if (error) return;
             opponent = [players lastObject];
             NSString *matchString = [NSString stringWithFormat:@"Commencing Match with %@", opponent.alias];
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:matchString message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
             [alert show];
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error creating match" message:error.localizedFailureReason delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
    [alert show];
}

#pragma mark - Start/Stop Games

- (void) finishMatch
{
    [match disconnect];
    [self cleanupGUI];
}

- (void) startMatch
{
    // Clean up any previous game
    sendingView.text = @"";
    receivingView.text = @"";

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

#pragma mark - View Setup
- (UIToolbar *) accessoryView
{
	tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
	tb.tintColor = [UIColor darkGrayColor];
	
	NSMutableArray *items = [NSMutableArray array];
	[items addObject:BARBUTTON(@"Clear", @selector(clearText))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	[items addObject:BARBUTTON(@"Done", @selector(leaveKeyboardMode))];
	tb.items = items;	
	
	return tb;
}

- (void) clearText
{
    sendingView.text = @"";
}

- (void) leaveKeyboardMode
{
    [sendingView resignFirstResponder];
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
            self.navigationItem.rightBarButtonItem = BARBUTTON(@"Match", @selector(startMatch));
            [self addInvitationHandler];
        }];
    }    
}

- (void) viewDidAppear:(BOOL)animated
{
    if (!sendingView)
    {
        sendingView = [[UITextView alloc] initWithFrame:CGRectZero];
        sendingView.editable = NO;
        sendingView.font = [UIFont fontWithName:@"Futura" size:14.0f];
        sendingView.backgroundColor = [UIColor colorWithRed:1.0f green:0.5f blue:0.5f alpha:1.0f];
        sendingView.inputAccessoryView = [self accessoryView];
        [self.view addSubview:sendingView];
    }
    CGRect sendingFrame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 80.0f);
    sendingView.frame = sendingFrame;
    
    if (!receivingView)
    {
        receivingView = [[UITextView alloc] initWithFrame:CGRectZero];
        receivingView.editable = NO;
        receivingView.font = [UIFont fontWithName:@"Futura" size:14.0f];
        receivingView.backgroundColor = [UIColor colorWithRed:0.5f green:0.5f blue:1.0f alpha:1.0f];
        [self.view addSubview:receivingView];
    }
    CGRect receivingFrame = CGRectMake(0.0f, 80.0f, self.view.bounds.size.width, 80.0f);
    receivingView.frame = receivingFrame;
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
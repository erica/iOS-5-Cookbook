/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "TestBedViewControllerSuper.h"


@interface TestBedViewController : TestBedViewControllerSuper 
{    
    BOOL startupResolved;
    BOOL opponentGoesFirst;
    
    NSNumber *localRoll;
    NSNumber *remoteRoll;

    UIButton *button;
}
@end

@implementation TestBedViewController
#pragma mark - gameplay

- (void) roll
{
    // 1d100
    unsigned int roll = random() % 100;
    localRoll = [NSNumber numberWithUnsignedInt:roll];
    // NSLog(@"You rolled %d", roll);
}

- (void) sendRoll: (NSString *) type
{
    [self roll];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:localRoll forKey:type];
    NSData *json = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    [match sendDataToAllPlayers:json withDataMode:GKMatchSendDataReliable error:nil];    
}

- (void) checkStartupWinner
{
    // Already resolved the startup winner?
    if (startupResolved)
        return;
    
    if (!remoteRoll || !localRoll)
    {
        [self performSelector:@selector(checkStartupWinner) withObject:nil afterDelay:1.0f];
        return;
    }
    
    NSLog(@"Remote roll: %@, local roll: %@", remoteRoll, localRoll);
    unsigned int local = localRoll.unsignedIntValue;
    unsigned int remote = remoteRoll.unsignedIntValue;
    
    if (local == remote)
    {
        NSLog(@"TIE!");
        remoteRoll = nil;
        localRoll = nil;
        [self sendRoll:GKROLLFORFIRST];
        return;
    }
    
    NSString *opponentName = self.opponentName;
    startupResolved = YES;
    localRoll = nil;
    remoteRoll = nil;

    if (remote > local)
    {
        // they go first.
        opponentGoesFirst = YES;
        self.title = [NSString stringWithFormat:@"%@'s turn", opponentName];
        showAlert(@"You lost the toss! %@ goes first. When it is your turn, the button in the center of the screen will activate. Press it then.", opponentName);
    }
    else
    {
        showAlert(@"You won the toss! Press the button in the center of the screen.");
        self.title = @"Your turn";
        button.enabled = YES;
    }
}

- (void) checkWinner
{
    assert(localRoll != nil);
    assert(remoteRoll != nil);
    
    // Both rolls are in. Who won?
    NSLog(@"Remote roll: %@, local roll: %@", remoteRoll, localRoll);
    unsigned int local = localRoll.unsignedIntValue;
    unsigned int remote = remoteRoll.unsignedIntValue;
    
    if (local == remote)
    {
        showAlert(@"That round was a tie (%d to %d)", local, local);
    }
    else if (remoteRoll.unsignedIntValue > localRoll.unsignedIntValue)
    {
        showAlert(@"%@ won that round (%d to %d)", self.opponentName, remote, local);
    }
    else
    {
        showAlert(@"You won that round. %d beats %d", local, remote);
    }
    
    // Reset both values
    localRoll = nil;
    remoteRoll = nil;
    
    // Reset GUI
    button.enabled = !opponentGoesFirst;
    if (opponentGoesFirst)
        self.title = [NSString stringWithFormat:@"%@'s turn", self.opponentName];
    else
        self.title = @"Your turn";
}

- (void)match:(GKMatch *) aMatch didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *key = [[dict allKeys] lastObject];
    if (!key) return;
    
    NSLog(@"Received Key: %@", key);
    
    if ([key isEqualToString:GKROLLFORFIRST])
    {
        remoteRoll = [dict objectForKey:key];
        [self checkStartupWinner];
        return;
    }

    if ([key isEqualToString:@"Roll"])
    {
        remoteRoll = [dict objectForKey:key];

        if (opponentGoesFirst)
        {
            self.title = @"Your turn";
            button.enabled = YES;
            return;
        }
        else
        {
            self.title = nil;
            button.enabled = NO;
            [self checkWinner];
            return;
        }
    }
}

- (void) pressButton: (id) sender
{
    // handle button press here
    button.enabled = NO;
    [self sendRoll:@"Roll"];
    
    if (opponentGoesFirst)
    {
        self.title = nil;
        [self checkWinner];
    }
    else
        self.title = [NSString stringWithFormat:@"%@'s turn", self.opponentName];
}

#pragma mark - GUI
- (void) activateGameGUI
{
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Quit", @selector(finishMatch));
    button.alpha = 1.0f;    
    matchStarted = YES;
    
    // start game play by rolling the die
    startupResolved = NO;
    [self sendRoll:GKROLLFORFIRST];
    [self checkStartupWinner];
}

- (void) cleanupGUI
{
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Match", @selector(startMatch));
    
    button.enabled = NO;
    button.alpha = 0.0f;
    
    matchStarted = NO;
    match = nil;
}

#pragma mark - View Setup
- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // seed random generator
    srandom(time(0));
    
    button = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [button addTarget:self action:@selector(pressButton:) forControlEvents:UIControlEventTouchUpInside];
    button.enabled = NO;
    button.alpha = 0.0f;
    [self.view addSubview:button];
    
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
    button.center = RECTCENTER(self.view.bounds);
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
/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "TestBedViewControllerSuper.h"
#import "ModalAlertDelegate.h"

@interface TestBedViewController : TestBedViewControllerSuper 
{    
    GKVoiceChat *chat;
    UIButton *talkButton;
}
@end

@implementation TestBedViewController
#pragma mark - gameplay

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
    NSString *answer = [self requestString];
    if (!answer) return;
    
    NSData *data = [answer dataUsingEncoding:NSUTF8StringEncoding];
    [match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:nil];    
}

- (void)match:(GKMatch *) aMatch didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    self.title = string;
}

#pragma mark - Voice
- (void) stopSpeaking
{
    chat.active = NO;
}

- (void) startSpeaking
{
    chat.active = YES;
}

- (BOOL) establishPlayAndRecordAudioSession
{
    NSLog(@"Establishing Audio Session");
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (!success)
    {
        NSLog(@"Error setting session category: %@", error.localizedFailureReason);
        return NO;
    }
    else
    {
        success = [audioSession setActive: YES error: &error];
        if (success)
        {
            NSLog(@"Audio session is active (play and record)");
            return YES;
        }
        else
        {
            NSLog(@"Error activating audio session: %@", error.localizedFailureReason);
            return NO;
        }
    }
    
    return NO;
}

- (void) muteChat: (GKVoiceChat *) aChat
{
    NSLog(@"Muting chat %@", aChat.name);
    for (NSString *playerID in aChat.playerIDs)
        [aChat setMute:YES forPlayer:playerID];
}

- (void) unmuteChat: (GKVoiceChat *) aChat
{  
    NSLog(@"Unmuting chat %@", aChat.name);
    for (NSString *playerID in aChat.playerIDs)
        [aChat setMute:NO forPlayer:playerID];
}


- (void) establishVoice
{
    if (![GKVoiceChat isVoIPAllowed])
        return;
    
    if (![self establishPlayAndRecordAudioSession])
        return;
    
    chat = [match voiceChatWithName:@"GeneralChat"];
    [chat start]; // stop with [chat end];   
    chat.active = NO; // disable mic by setting to NO
    chat.volume = 1.0f; // adjust as needed.
    
    // Establishing team chats and direct chat
    /*
     e.g. directChat = [match voiceChatWithName:@"Private Channel 1"];
     Each unique name specifies the chat 
     */
    
    // muting: [chat setMute:YES/NO forPlayer: playerID];
    
    chat.playerStateUpdateHandler = ^(NSString *playerID, GKVoiceChatPlayerState state) {
        switch (state)
        {
            case GKVoiceChatPlayerSpeaking:
                // Highlight player's picture
                break;
            case GKVoiceChatPlayerSilent:
                // Dim player's picture
                break;
            case GKVoiceChatPlayerConnected:
                // Show player name/picture
                break;
            case GKVoiceChatPlayerDisconnected:
                // Hide player name/picture
                break;
        } };
}

#pragma mark - GUI
- (void) activateGameGUI
{
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Play", @selector(play));
    self.navigationItem.leftBarButtonItem = BARBUTTON(@"Quit", @selector(finishMatch));
    [self establishVoice];
}

- (void) cleanupGUI
{
    self.title = nil;
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Match", @selector(startMatch));
    self.navigationItem.leftBarButtonItem = nil;
    
    [chat stop];
    chat = nil;
}
#pragma mark - View Setup
- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // seed random generator
    srandom(time(0));
        
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
    if (!talkButton)
    {
        talkButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [talkButton setTitle:@"Speak" forState:UIControlStateNormal];
        talkButton.frame = CGRectMake(0.0f, 0.0f, 200.0f, 40.0f);
        [self.view addSubview:talkButton];
        
        [talkButton addTarget:self action:@selector(startSpeaking) forControlEvents:UIControlEventTouchDown];
        [talkButton addTarget:self action:@selector(stopSpeaking) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    }
    
    talkButton.center = RECTCENTER(self.view.bounds);
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
/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface TestBedViewController : UIViewController <AVAudioPlayerDelegate>
{
    AVAudioPlayer *player;
}
@end

@implementation TestBedViewController

- (void) setupAudio
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"InTheMood" ofType:@"mp3"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        return;
    
    NSError *error;
	player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
    if (!player)
    {
        NSLog(@"Could not establish player: %@", error.localizedFailureReason);
        return;
    }
	player.delegate = self;
	player.numberOfLoops = 999;
    
    // Set up a media playback session that mixes its audio
    AudioSessionInitialize(NULL, NULL, NULL, (void *) (__bridge CFTypeRef) self);
	AudioSessionSetActive(true);
	UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
	UInt32 mixWithOthers = 1;
	AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(mixWithOthers), &mixWithOthers);
}

- (void) play
{
    player.volume = 0.0f;
    [player play];

    // fade in the audio over a couple of seconds
	for (int i = 1; i <= 20; i++)
	{
		player.volume = i / 10.0f;
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
	}
}

- (void)  pause
{
    // fade out the audio over a couple of seconds
	for (int i = 19; i >= 0; i--)
	{
		player.volume = i / 10.0f;
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
	}

    [player pause];
}

#pragma mark - Skeleton
- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupAudio];
    self.title = @"Press the HOME button";
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
    TestBedViewController *tbvc;
}
@end
@implementation TestBedAppDelegate
- (void)applicationDidEnterBackground:(UIApplication *)application 
{
	[tbvc play];
}


- (void)applicationWillEnterForeground:(UIApplication *)application 
{
	[tbvc pause];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    // [application setStatusBarHidden:YES];
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	tbvc = [[TestBedViewController alloc] init];
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
/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

@interface TestBedViewController : UIViewController
{
	SystemSoundID mysound;
}
@end

@implementation TestBedViewController

- (void) dealloc
{
    if (mysound) AudioServicesDisposeSystemSoundID(mysound);
}

- (void) playSound
{
	if ([MPMusicPlayerController iPodMusicPlayer].playbackState ==  MPMusicPlaybackStatePlaying)
		AudioServicesPlayAlertSound(mysound);
	else
		AudioServicesPlaySystemSound(mysound);
}

- (void) vibrate
{
	AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
	// create the sound
	NSString *sndpath = [[NSBundle mainBundle] pathForResource:@"basicsound" ofType:@"wav"];
	CFURLRef baseURL = (__bridge CFURLRef)[NSURL fileURLWithPath:sndpath];
	
	// Identify it as not a UI Sound
    AudioServicesCreateSystemSoundID(baseURL, &mysound);
	AudioServicesPropertyID flag = 0;  // 0 means always play
	AudioServicesSetProperty(kAudioServicesPropertyIsUISound, sizeof(SystemSoundID), &mysound, sizeof(AudioServicesPropertyID), &flag);
	
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Sound", @selector(playSound));
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Vibrate", @selector(vibrate));
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
    [application setStatusBarHidden:YES];
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
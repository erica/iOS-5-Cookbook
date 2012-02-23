/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define RECTCENTER(rect) CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)
#define RESIZABLE(_VIEW_) [_VIEW_ setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface TestBedViewController : UIViewController
{
	AVAudioPlayer *player;
}
@end

@implementation TestBedViewController

- (BOOL) prepAudio
{
	// Check for the file. "Drumskul" was released as a public domain audio loop on archive.org as part of "loops2try2". 
	NSError *error;
	NSString *path = [[NSBundle mainBundle] pathForResource:@"loop" ofType:@"mp3"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return NO;
	
	// Initialize the player
	player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
	if (!player)
	{
		NSLog(@"Could not establish AV Player: %@", error.localizedFailureReason);
		return NO;
	}
	
	// Prepare the player and set the loops to, basically, unlimited
	[player prepareToPlay];
	[player setNumberOfLoops:999999];

	return YES;
}

- (void) viewDidAppear: (BOOL) animated
{
	// Start playing at no-volume
	player.volume = 0.0f;
	[player play];
	
	// fade in the audio over a second
	for (int i = 1; i <= 10; i++)
	{
		player.volume = i / 10.0f;
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
	}
	
	// Add the push button
	self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void) viewWillDisappear: (BOOL) animated
{
	// fade out the audio over a second
	for (int i = 9; i >= 0; i--)
	{
		player.volume = i / 10.0f;
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
	}
	
	[player pause];
}

- (void) push
{
	// Create a simple new view controller
	UIViewController *vc = [[UIViewController alloc] init];
	vc.view.backgroundColor = [UIColor whiteColor];
	vc.title = @"No Sounds";
	
	// Disable the now-pressed right-button
	self.navigationItem.rightBarButtonItem.enabled = NO;
    
	// Push the new view controller
	[self.navigationController pushViewController:vc animated:YES];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Push", @selector(push));
    self.title = @"Looped Sounds";
    [self prepAudio];
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
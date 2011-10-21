/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AccelerometerHelper.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]

@interface TestBedViewController : UIViewController <UIAccelerometerDelegate>
{
	IBOutlet UITextField *sensitivity;
	IBOutlet UITextField *timelock;
	IBOutlet UILabel *acceleration;
	IBOutlet UITextView *feedback;
	
	SystemSoundID sound;
}
@end

@implementation TestBedViewController
#pragma mark  sounds

- (void) loadSound: (SystemSoundID *) aSound called: (NSString *) aName
{
	NSString *sndpath = [[NSBundle mainBundle] pathForResource:aName ofType:@"aif"];
	CFURLRef baseURL = (__bridge CFURLRef)[NSURL fileURLWithPath:sndpath];
    AudioServicesCreateSystemSoundID(baseURL, aSound);
	AudioServicesPropertyID flag = 0;
	AudioServicesSetProperty(kAudioServicesPropertyIsUISound, sizeof(SystemSoundID), aSound, sizeof(AudioServicesPropertyID), &flag);
}

- (void) playSound: (SystemSoundID) aSound
{
	AudioServicesPlaySystemSound(aSound);
}

-(void) dealloc
{
	if (sound) AudioServicesDisposeSystemSoundID(sound);
}

#pragma mark AccelerometerHelper

- (IBAction) updateTimeLockout: (UISlider *) slider
{
	timelock.text = [NSString stringWithFormat:@"%4.2f", slider.value];
	[[AccelerometerHelper sharedInstance] setLockout:slider.value];
}

- (IBAction) updateSensitivity: (UISlider *) slider
{
	sensitivity.text = [NSString stringWithFormat:@"%4.2f", slider.value];
	[[AccelerometerHelper sharedInstance] setSensitivity:slider.value];
}

- (void) ping
{
	float change = [[AccelerometerHelper sharedInstance] dAngle];
	acceleration.text = [NSString stringWithFormat:@"%4.2f", change];
}

- (void) shake
{
	float change = [[AccelerometerHelper sharedInstance] dAngle];
	feedback.text = [NSString stringWithFormat:@"Triggered at: %4.2f", change];
	[self playSound:sound];
}

- (void) viewDidLoad
{
	[AccelerometerHelper sharedInstance].delegate = self;
	[self loadSound:&sound called:@"whoosh"];
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
/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define RECTCENTER(rect) CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))

@interface TestBedViewController : UIViewController <UIAccelerometerDelegate>
{
    CMMotionManager *motionManager;
    UIImageView *imageView;
}
@end

@implementation TestBedViewController
- (void) shutDownMotionManager
{
    NSLog(@"Shutting down motion manager");
    [motionManager stopDeviceMotionUpdates];
    motionManager = nil;
}

- (void) establishMotionManager
{
    if (motionManager)
        [self shutDownMotionManager];

    NSLog(@"Establishing motion manager");
    
    // Establish the motion manager
    motionManager = [[CMMotionManager alloc] init];
    if (motionManager.deviceMotionAvailable)
        [motionManager 
         startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
         withHandler: ^(CMDeviceMotion *motion, NSError *error) {
             CATransform3D transform;
             transform = CATransform3DMakeRotation(motion.attitude.pitch, 1, 0, 0);
             transform = CATransform3DRotate(transform, motion.attitude.roll, 0, 1, 0);
             transform = CATransform3DRotate(transform, motion.attitude.yaw, 0, 0, 1);
             imageView.layer.transform = transform;
     }];
}

- (void) viewDidAppear: (BOOL) animated
{
    NSString *imageName = IS_IPAD ? @"iPadArt.png" : @"iPhoneArt.png";
    UIImage *image = [UIImage imageNamed:imageName];
    imageView = [[UIImageView alloc] initWithImage:image];
    imageView.center = RECTCENTER(self.view.bounds);
    [self.view addSubview:imageView];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
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
- (void) applicationWillResignActive:(UIApplication *)application
{
    [tbvc shutDownMotionManager];
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
    [tbvc establishMotionManager];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    [application setStatusBarHidden:YES];
    
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	tbvc = [[TestBedViewController alloc] init];
    window.rootViewController = tbvc;
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
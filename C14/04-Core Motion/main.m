/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>

#define RECTCENTER(rect) CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
#define SIGN(x)	((x < 0.0f) ? -1.0f : 1.0f)

@interface TestBedViewController : UIViewController <UIAccelerometerDelegate>
{
    UIImageView *butterfly;

	float xaccel;
	float xvelocity;
    
	float yaccel;
	float yvelocity;
    
    float mostRecentAngle;
    
    CMMotionManager *motionManager;
    NSTimer *timer;
}
@end

@implementation TestBedViewController
- (void) tick
{
    butterfly.transform = CGAffineTransformIdentity;
    
	// Move the butterfly according to the current velocity vector
    CGRect rect = CGRectOffset(butterfly.frame, xvelocity, 0.0f);
    if (CGRectContainsRect(self.view.bounds, rect))
        butterfly.frame = rect;

    rect = CGRectOffset(butterfly.frame, 0.0f, yvelocity);
    if (CGRectContainsRect(self.view.bounds, rect))
        butterfly.frame = rect;
    
    butterfly.transform = CGAffineTransformMakeRotation(mostRecentAngle + M_PI_2);
}

- (void) shutDownMotionManager
{
    NSLog(@"Shutting down motion manager");
    [motionManager stopAccelerometerUpdates];
    motionManager = nil;
    
    [timer invalidate];
    timer = nil;
}

- (void) establishMotionManager
{
    if (motionManager)
        [self shutDownMotionManager];

    NSLog(@"Establishing motion manager");
    
    // Establish the motion manager
    motionManager = [[CMMotionManager alloc] init];
    if (motionManager.accelerometerAvailable)
        [motionManager 
         startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] 
         withHandler:^(CMAccelerometerData *data, NSError *error)
         {
             // extract the acceleration components
             float xx = -data.acceleration.x;
             float yy = data.acceleration.y;
             mostRecentAngle = atan2(yy, xx);
             
             // Has the direction changed?
             float accelDirX = SIGN(xvelocity) * -1.0f; 
             float newDirX = SIGN(xx);
             float accelDirY = SIGN(yvelocity) * -1.0f;
             float newDirY = SIGN(yy);
             
             // Accelerate. To increase viscosity lower the additive value
             if (accelDirX == newDirX) xaccel = (abs(xaccel) + 0.85f) * SIGN(xaccel);
             if (accelDirY == newDirY) yaccel = (abs(yaccel) + 0.85f) * SIGN(yaccel);
             
             // Apply acceleration changes to the current velocity
             xvelocity = -xaccel * xx;
             yvelocity = -yaccel * yy;
         }];
    
    
	// Start the physics timer
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.03f target: self selector: @selector(tick) userInfo: nil repeats: YES];
}

- (void) initButterfly
{
    CGSize size;
    
	// Load the animation cells
	NSMutableArray *butterflies = [NSMutableArray array];
	for (int i = 1; i <= 17; i++) 
    {
        NSString *fileName = [NSString stringWithFormat:@"bf_%d.png", i];
        UIImage *image = [UIImage imageNamed:fileName];
        size = image.size;
		[butterflies addObject:image];
    }
	
	// Begin the animation
	butterfly = [[UIImageView alloc] initWithFrame:(CGRect){.size=size}];
	[butterfly setAnimationImages:butterflies];
	butterfly.animationDuration = 0.75f;
	[butterfly startAnimating];

	// Set the butterfly's initial speed and acceleration
	xaccel = 2.0f;
	yaccel = 2.0f;
	xvelocity = 0.0f;
	yvelocity = 0.0f;
	
    // Add the butterfly
	butterfly.center = RECTCENTER(self.view.bounds);
	[self.view addSubview:butterfly];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initButterfly];
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
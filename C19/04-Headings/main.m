/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface TestBedViewController : UIViewController <CLLocationManagerDelegate>
{
    UIImageView *arrowView;
    CLLocationManager *locManager;
}
@end

@implementation TestBedViewController

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location manager error: %@", error.localizedFailureReason);
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    CGFloat heading = -M_PI * newHeading.magneticHeading / 180.0f;
    arrowView.transform = CGAffineTransformMakeRotation(heading);
}


- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    [self.view addSubview:arrowView];
    
    if (!CLLocationManager.locationServicesEnabled)
    {
        NSLog(@"User has opted out of location services");
        return;
    }
    
    locManager = [[CLLocationManager alloc] init];
    locManager.delegate = self;

    if (CLLocationManager.headingAvailable) 
        [locManager startUpdatingHeading];
    else
        arrowView.alpha = 0.0f;

}

#pragma mark -

- (void) viewDidAppear:(BOOL)animated
{
    arrowView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self viewDidAppear:NO];
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
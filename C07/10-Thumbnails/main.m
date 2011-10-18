/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utilities.h"
#import "Geometry.h"
#import "UIImage-Utilities.h"
#import "Orientation.h"
#import "CameraImageHelper.h"

@interface TestBedViewController : UIViewController
{
    UIImageView *imageView;
    CameraImageHelper *helper;
    UISegmentedControl *seg;
}
@end

@implementation TestBedViewController

// Switch between cameras
- (void) switch: (id) sender
{
    [helper switchCameras];
}

- (void) snap: (NSTimer *) timer
{
    UIImageOrientation orientation = currentImageOrientation(helper.isUsingFrontCamera, NO);
    UIImage *baseImage = [UIImage imageWithCIImage:helper.ciImage orientation:orientation];
    
    CGSize destSize = CGSizeMake(300.0f, 300.0f);
    
    if (seg.selectedSegmentIndex == 0) 
        imageView.image = [baseImage fitInSize:destSize];
    else if (seg.selectedSegmentIndex == 1)
        imageView.image = [baseImage centerInSize:destSize];
    else
        imageView.image = [baseImage fillSize:destSize];
}

- (void) viewDidAppear:(BOOL)animated
{
    imageView.center = CGRectGetCenter(self.view.bounds);
}

- (void) viewDidLayoutSubviews
{
    imageView.center = CGRectGetCenter(self.view.bounds);
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    
    // Switch between cameras
    if ([CameraImageHelper numberOfCameras] > 1)
        self.navigationItem.leftBarButtonItem = BARBUTTON(@"Switch", @selector(switch:));
    
            
    imageView = [[UIImageView alloc] initWithFrame:(CGRect){.size=CGSizeMake(300.0f, 300.0f)}];
    imageView.backgroundColor = [UIColor darkGrayColor];
    imageView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:imageView];
    
    NSArray *items = [@"Fit*Center*Fill" componentsSeparatedByString:@"*"];
    seg = [[UISegmentedControl alloc] initWithItems:items];
    seg.selectedSegmentIndex = 0;
    self.navigationItem.titleView = seg;

    helper = [CameraImageHelper helperWithCamera:kCameraFront];
    [helper startRunningSession];
    
    [NSTimer scheduledTimerWithTimeInterval:0.03f target:self selector:@selector(snap:) userInfo:nil repeats:YES];    
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
/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utilities.h"
#import "Geometry.h"
#import "Orientation.h"
#import "UIImage-Utilities.h"
#import "CameraImageHelper.h"

@interface TestBedViewController : UIViewController
{
    UIImageView *imageView;
    CameraImageHelper *helper;
    UIView *preview;
}
@end

@implementation TestBedViewController

// Switch between cameras
- (void) switch: (id) sender
{
    [helper switchCameras];
}

- (void) process: (id) sender
{
    // Prepare the interface
    self.navigationItem.rightBarButtonItem = nil;
    UIAlertView *alertView = [[UIAlertView alloc] 
                              initWithTitle:@"\n\nProcessing\nPlease wait." 
                              message:nil delegate:self cancelButtonTitle:nil 
                              otherButtonTitles:nil];
    [alertView show];
    
    // Create a background queue for processing
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:
     ^{
         UIImage *theImage = helper.currentImage;
         UIImage *processed = [theImage convolveImageWithEdgeDetection];
         UIImage *oriented = [UIImage imageWithCGImage:processed.CGImage scale:1.0f orientation:currentImageOrientation(helper.isUsingFrontCamera, NO)];

         // Update the image on the main thread using the main queue
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             imageView.image = oriented;
             [alertView dismissWithClickedButtonIndex:-1 animated:YES];
             self.navigationItem.rightBarButtonItem = BARBUTTON(@"Process", @selector(process:));
         }];         
     }];
}

- (void) viewDidAppear:(BOOL)animated
{
    imageView.frame = self.view.bounds;
    imageView.center = CGRectGetCenter(self.view.bounds);
    preview.center = CGPointMake(imageView.center.x, 60.0f);
}

- (void) viewDidLayoutSubviews
{
    [helper layoutPreviewInView:preview];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    
    // Switch between cameras
    if ([CameraImageHelper numberOfCameras] > 1)
        self.navigationItem.leftBarButtonItem = BARBUTTON(@"Switch", @selector(switch:));
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Process", @selector(process:));
    
    imageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    imageView.contentMode = UIViewContentModeCenter;
    RESIZABLE(imageView);
    [self.view addSubview:imageView];
    
    helper = [CameraImageHelper helperWithCamera:kCameraFront];
    [helper startRunningSession];
    
    preview = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 100.0f)];
    preview.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:preview];
    [helper embedPreviewInView:preview];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIDeviceOrientationIsLandscape(interfaceOrientation);
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
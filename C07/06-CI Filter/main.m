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
    
    BOOL useFilter;
}
@end

@implementation TestBedViewController

// Switch between cameras
- (void) switch: (id) sender
{
    [helper switchCameras];
}

- (void) toggleFilter: (id) sender
{
    useFilter = !useFilter;
}

- (void) snap: (NSTimer *) timer
{
    UIImageOrientation orientation = currentImageOrientation(helper.isUsingFrontCamera, NO);
    if (useFilter)
    {
        CIFilter *sepiaFilter = [CIFilter filterWithName:@"CISepiaTone"
                                           keysAndValues: @"inputImage", helper.ciImage, nil];
        [sepiaFilter setDefaults];  
        [sepiaFilter setValue:[NSNumber numberWithFloat:0.75f] forKey:@"inputIntensity"];
        CIImage *sepiaImage = [sepiaFilter valueForKey:kCIOutputImageKey];
        if (sepiaImage)
            imageView.image = [UIImage imageWithCIImage:sepiaImage orientation:orientation];
        else NSLog(@"Missing sepia image");
    }
    else
        imageView.image = [UIImage imageWithCIImage:helper.ciImage orientation:orientation];
}

- (void) viewDidAppear:(BOOL)animated
{
    imageView.frame = self.view.bounds;
    imageView.center = CGRectGetCenter(self.view.bounds);
}

- (void) viewDidLayoutSubviews
{
    [helper layoutPreviewInView:imageView];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    
    // Switch between cameras
    if ([CameraImageHelper numberOfCameras] > 1)
        self.navigationItem.leftBarButtonItem = BARBUTTON(@"Switch", @selector(switch:));
    
            
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Toggle Filter", @selector(toggleFilter:));
        
    imageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    RESIZABLE(imageView);
    [self.view addSubview:imageView];

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
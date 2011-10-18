/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utilities.h"
#import "UIImage-Utilities.h"
#import "Geometry.h"
#import "Orientation.h"
#import "exifGeometry.h"
#import "CameraImageHelper.h"

@interface TestBedViewController : UIViewController
{
    UIImageView *imageView;
    CameraImageHelper *helper;
    CIImage *ciImage;
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
    UIImageOrientation imageOrientation = currentImageOrientation(helper.isUsingFrontCamera, NO);
    
    ciImage = helper.ciImage;
    UIImage *baseImage = [UIImage imageWithCIImage:ciImage orientation:imageOrientation];    
    CGRect imageRect = (CGRect){.size = baseImage.size};

    NSDictionary *detectorOptions = [NSDictionary dictionaryWithObject:CIDetectorAccuracyLow forKey:CIDetectorAccuracy]; 
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    
    ExifOrientation detectOrientation = detectorEXIF(helper.isUsingFrontCamera, NO);
    NSLog(@"Current orientation: %@", exifOrientationNameFromOrientation(detectOrientation));
    
    NSDictionary *imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:detectOrientation] forKey:CIDetectorImageOrientation];
    NSArray *features = [detector featuresInImage:ciImage options:imageOptions];
    if (!features.count) return;
    CIFaceFeature *feature = [features lastObject]; // only one at a time
    
    CGRect rect = rectInEXIF(detectOrientation, feature.bounds, imageRect);
    if (deviceIsPortrait() && helper.isUsingFrontCamera) // workaround
    {
        rect.origin = CGPointFlipHorizontal(rect.origin, imageRect);
        rect.origin = CGPointOffset(rect.origin, -rect.size.width, 0.0f);
    }
    
    // Expand by about 10%
    CGPoint center = CGRectGetCenter(rect);
    CGFloat width = rect.size.width * 1.1f;
    CGFloat height = rect.size.height * 1.1f;
    CGRect newRect = CGRectAroundCenter(center, width / 2.0f, height / 2.0f);

    UIImage *newImage = [baseImage subImageWithBounds:newRect];
    imageView.image = newImage;
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
        
    imageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    RESIZABLE(imageView);
    [self.view addSubview:imageView];

    helper = [CameraImageHelper helperWithCamera:kCameraFront];
    [helper startRunningSession];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(snap:) userInfo:nil repeats:YES];    
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
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

    UIGraphicsBeginImageContext(baseImage.size);
    [baseImage drawInRect:imageRect];
    
    for (CIFaceFeature *feature in features)
    {
        CGRect rect = rectInEXIF(detectOrientation, feature.bounds, imageRect);
        if (deviceIsPortrait() && helper.isUsingFrontCamera) // workaround
        {
            rect.origin = CGPointFlipHorizontal(rect.origin, imageRect);
            rect.origin = CGPointOffset(rect.origin, -rect.size.width, 0.0f);
        }

        [[[UIColor blackColor] colorWithAlphaComponent:0.3f] set];
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
        [path fill];

        if (feature.hasLeftEyePosition)
        {
            [[[UIColor redColor] colorWithAlphaComponent:0.5f] set];
            CGPoint position = feature.leftEyePosition;
            CGPoint pt = pointInEXIF(detectOrientation, position, imageRect);
            if (deviceIsPortrait() && helper.isUsingFrontCamera) // workaround
                pt = CGPointFlipHorizontal(pt, imageRect);
            
            UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:pt radius:30.0f startAngle:0.0f endAngle:2 * M_PI clockwise:YES];
            [path fill];
        }
        
        if (feature.hasRightEyePosition)
        {
            [[[UIColor blueColor] colorWithAlphaComponent:0.5f] set];
            CGPoint position = feature.rightEyePosition;
            CGPoint pt = pointInEXIF(detectOrientation, position, imageRect);
            if (deviceIsPortrait() && helper.isUsingFrontCamera) // workaround
                pt = CGPointFlipHorizontal(pt, imageRect);

            UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:pt radius:30.0f startAngle:0.0f endAngle:2 * M_PI clockwise:YES];
            [path fill];
        }
        
        if (feature.hasMouthPosition)
        {
            [[[UIColor greenColor] colorWithAlphaComponent:0.5f] set];
            CGPoint position = feature.mouthPosition;
            CGPoint pt = pointInEXIF(detectOrientation, position, imageRect);
            if (deviceIsPortrait() && helper.isUsingFrontCamera) // workaround
                pt = CGPointFlipHorizontal(pt, imageRect);

            UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:pt radius:30.0f startAngle:0.0f endAngle:2 * M_PI clockwise:YES];
            [path fill];
        }

    }
    
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
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
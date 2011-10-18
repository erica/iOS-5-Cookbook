/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Utilities.h"

@interface TestBedViewController : UIViewController <UIScrollViewDelegate>
{
    UIImageView *imageView;
    UIScrollView *scrollView;
}
@end

@implementation TestBedViewController

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    // Specify which view responds to zoom events
    return imageView;
}

- (void) viewDidAppear:(BOOL)animated
{
    scrollView.frame = self.view.bounds;
    scrollView.center = CGRectGetCenter(self.view.bounds);
    
    if (imageView.image)
    {
        float scalex = scrollView.frame.size.width / imageView.image.size.width;
        float scaley = scrollView.frame.size.height / imageView.image.size.height;
        scrollView.zoomScale = MIN(scalex, scaley);
        scrollView.minimumZoomScale = MIN(scalex, scaley);
    }
}

- (void) viewDidLayoutSubviews
{
    [self viewDidAppear:NO];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    
    scrollView = [[UIScrollView alloc] init];
    scrollView.delegate = self;
    scrollView.maximumZoomScale = 4.0f;
    RESIZABLE(scrollView);
    [self.view addSubview:scrollView];
    
    imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeCenter;
    [scrollView addSubview:imageView];
    
    NSString *map = @"http://maps.weather.com/images/maps/current/curwx_720x486.jpg";
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:
     ^{
         // Load the weather data
         NSURL *weatherURL = [NSURL URLWithString:map];
         NSData *imageData = [NSData dataWithContentsOfURL:weatherURL];
         
         // Update the image on the main thread using the main queue
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             UIImage *weatherImage = [UIImage imageWithData:imageData];
             imageView.userInteractionEnabled = YES;
             imageView.image = weatherImage;
             imageView.frame = (CGRect){.size = weatherImage.size};
             
             float scalex = scrollView.frame.size.width / weatherImage.size.width;
             float scaley = scrollView.frame.size.height / weatherImage.size.height;
             scrollView.zoomScale = MIN(scalex, scaley);
             scrollView.minimumZoomScale = MIN(scalex, scaley);
             scrollView.contentSize = weatherImage.size;
         }];
     }];
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
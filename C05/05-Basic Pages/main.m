/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "BookController.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]


@interface TestBedViewController : UIViewController <BookControllerDelegate>
{
    BookController *bookController;
}
@end

@implementation TestBedViewController

// Provide a view controller on demand for the given page number
- (id) viewControllerForPage: (int) pageNumber
{    
    if ((pageNumber < 0) || (pageNumber > 9)) return nil;
    float targetWhite = 0.9f - (pageNumber / 10.0f);
    
    // Establish a new controller
    UIViewController *controller = [BookController rotatableViewController];
    
    // Draw a shaded swatch
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    UIGraphicsBeginImageContext(appRect.size);
    [[UIColor colorWithWhite:targetWhite alpha:1.0f] set];
    [[UIBezierPath bezierPathWithRoundedRect:CGRectInset(appRect, 120.0f, 120.0f) cornerRadius:32.0f] fill];
    
    CGRect thinRect = CGRectMake(appRect.size.width - 10.0f, 0.0f, 10.0f, appRect.size.height);
    [[UIColor blackColor] set];
    CGContextFillRect(UIGraphicsGetCurrentContext(), thinRect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Add it as an image
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [controller.view addSubview:imageView];
    
    // Add a label
    UILabel *textLabel = [[UILabel alloc] initWithFrame:(CGRect){.size = CGSizeMake(200.0f, 40.0f)}];
    textLabel.text = [NSString stringWithFormat:@"%0.0f%% White", 100 * targetWhite];
    textLabel.font = [UIFont fontWithName:@"Futura" size:30.0f];
    textLabel.center = CGPointMake(150.0f, 40.0f);
    [controller.view addSubview:textLabel];
   
    return controller;
}

- (void) viewDidLoad
{
    // Add the child controller, and set it to the first page
    [self.view addSubview:bookController.view];
    [self addChildViewController:bookController];
    [bookController didMoveToParentViewController:self];
    [bookController moveToPage:0];
}

- (void) loadView
{
    [super loadView];

    // Build the view
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    self.view = [[UIView alloc] initWithFrame: appRect];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // Establish the page view controller
    bookController = [BookController bookWithDelegate:self];
    bookController.view.frame = (CGRect){.size = appRect.size};
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
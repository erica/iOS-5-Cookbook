/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "RotatingSegue.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_LANDSCAPE (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))

@interface TestBedViewController : UIViewController
{
    NSArray *childControllers;
    UIView *backsplash;
    UIPageControl *pageControl;
    int vcIndex;
}
@end

@implementation TestBedViewController

// Informal delegate method
- (void) segueDidComplete
{
    pageControl.currentPage = vcIndex;
}

// Transition to new view using custom segue
- (void) switchToView: (int) newIndex goingForward: (BOOL) goesForward
{
    if (vcIndex == newIndex) return;
        
    // Segue to the new controller
    UIViewController *source = [childControllers objectAtIndex:vcIndex];
    UIViewController *destination = [childControllers objectAtIndex:newIndex];
    RotatingSegue *segue = [[RotatingSegue alloc] initWithIdentifier:@"segue" source:source destination:destination];  
    segue.goesForward = goesForward;
    segue.delegate = self;    
    [segue perform];
    
    vcIndex = newIndex;
}

// Go forward
- (void) progress: (id) sender
{
    int newIndex = ((vcIndex + 1) % childControllers.count);  
    [self switchToView:newIndex goingForward:YES];
}

// Go backwards
- (void) regress: (id) sender
{
    int newIndex = vcIndex - 1;
    if (newIndex < 0) newIndex = childControllers.count - 1;
    [self switchToView:newIndex goingForward:NO];
}

// Establish core interface
- (void) viewDidLoad
{
    // Create a basic background.
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor blackColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // Create backsplash for animation support
    backsplash = [[UIView alloc] initWithFrame:CGRectInset(self.view.frame, 50.0f, 50.0f)];
    backsplash.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:backsplash];
    
    // Add a page view controller
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 40.0f)];
    pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    pageControl.currentPage = 0;
    pageControl.numberOfPages = 4;
    [self.view addSubview:pageControl];
    
    // Load child array from storyboard
    UIStoryboard *aStoryboard = [UIStoryboard storyboardWithName:@"child" bundle:[NSBundle mainBundle]];
    childControllers = [NSArray arrayWithObjects:
                        [aStoryboard instantiateViewControllerWithIdentifier:@"0"],
                        [aStoryboard instantiateViewControllerWithIdentifier:@"1"],
                        [aStoryboard instantiateViewControllerWithIdentifier:@"2"],
                        [aStoryboard instantiateViewControllerWithIdentifier:@"3"],
                        nil];
    
    UISwipeGestureRecognizer *leftSwiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(progress:)];
    leftSwiper.direction = UISwipeGestureRecognizerDirectionLeft;
    leftSwiper.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:leftSwiper];
    
    UISwipeGestureRecognizer *rightSwiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(regress:)];
    rightSwiper.direction = UISwipeGestureRecognizerDirectionRight;
    rightSwiper.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:rightSwiper];

    // Set each child as a child view controller, setting its tag and frame
    for (UIViewController *controller in childControllers)
    {
        controller.view.tag = 1066;
        controller.view.frame = backsplash.bounds;
        [self addChildViewController:controller];
    }

    // Initialize scene with first child controller
    vcIndex = 0;
    UIViewController *controller = (UIViewController *)[childControllers objectAtIndex:0];
    [backsplash addSubview:controller.view];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
     for (UIViewController *controller in childControllers)
          controller.view.frame = backsplash.bounds;
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
/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

@interface TappableView : UIView 
@end

@implementation TappableView
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Uncomment to make the view disappear on touch
    // [self removeFromSuperview];
}
@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController

- (void) removeOverlay: (UIView *) overlayView
{
    [overlayView removeFromSuperview];
}

- (void) action: (id) sender
{
    UIWindow *window = self.view.window;
    TappableView *overlayView = [[TappableView alloc] initWithFrame:window.bounds];
    overlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    overlayView.userInteractionEnabled = YES;
    
    UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiv.center = CGPointMake(CGRectGetMidX(overlayView.bounds), CGRectGetMidY(overlayView.bounds));
    [aiv startAnimating];
    
    [overlayView addSubview:aiv];
    [window addSubview:overlayView];
    
    // Comment out if you are using touch-to-remove
    [self performSelector:@selector(removeOverlay:) withObject:overlayView afterDelay:5.0f];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
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
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
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
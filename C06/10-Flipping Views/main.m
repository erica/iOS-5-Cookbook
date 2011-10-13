/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

CGPoint CGRectGetCenter(CGRect rect)
{
    CGPoint pt;
    pt.x = CGRectGetMidX(rect);
    pt.y = CGRectGetMidY(rect);
    return pt;
}

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

@interface TestBedViewController : UIViewController
{
    UIImageView *purple;
	UIImageView *maroon;
	UISegmentedControl *seg;
    BOOL fromPurple;
}
@end

@implementation TestBedViewController

- (void) flip: (id) sender
{
	self.navigationItem.rightBarButtonItem.enabled = NO;
	[UIView transitionFromView: fromPurple ? purple : maroon
						toView: fromPurple ? maroon : purple 
					  duration: 1.0f
					   options: seg.selectedSegmentIndex ? UIViewAnimationOptionTransitionCurlUp : UIViewAnimationOptionTransitionFlipFromLeft
					completion: ^(BOOL done){
						self.navigationItem.rightBarButtonItem.enabled = YES;
						fromPurple = !fromPurple;
                    }];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Flip", @selector(flip:));
    
    // Create the purple
	purple = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BFlyCircle.png"]];
	[self.view addSubview:purple];
	fromPurple = YES;
	
	// Create the maroon
	maroon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BFlyCircleMaroon.png"]];
    
    // Create the option segments
	seg = [[UISegmentedControl alloc] initWithItems:[@"Flip Curl" componentsSeparatedByString:@" "]];
	seg.segmentedControlStyle = UISegmentedControlStyleBar;
	seg.selectedSegmentIndex = 0;
	self.navigationItem.titleView = seg;
}

- (void) viewDidAppear:(BOOL)animated
{
    maroon.center = CGRectGetCenter(self.view.bounds);
    purple.center = CGRectGetCenter(self.view.bounds);
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    maroon.center = CGRectGetCenter(self.view.bounds);
    purple.center = CGRectGetCenter(self.view.bounds);
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
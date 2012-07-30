/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UIView-SubviewGeometry.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

@interface TestBedViewController : UIViewController
{
    UIImageView *butterflyView;
}
@end

@implementation TestBedViewController
- (void) updateButterfly: (NSTimer *) timer
{
	UIView *butterfly = [self.view viewWithTag:300];
	
	[UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5f];
	
	butterfly.center = [butterfly randomCenterInView:self.view withInset:10.0f];
	
	[UIView commitAnimations];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    self.view.backgroundColor = [UIColor whiteColor];
    
	// Load butterfly images
	NSMutableArray *bflies = [NSMutableArray array];
	for (int i = 1; i <= 17; i++)
		[bflies addObject:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"bf_%d", i] ofType:@"png"]]];
    
	butterflyView = [[UIImageView alloc] initWithFrame:CGRectMake(40.0f, 300.0f, 60.0f, 60.0f)];
	butterflyView.tag = 300;
	butterflyView.animationImages = bflies;
	butterflyView.animationDuration = 0.75f;
	[self.view addSubview:butterflyView];
	[butterflyView startAnimating];
	
	// start timer
	[NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(updateButterfly:) userInfo:nil repeats:YES];
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
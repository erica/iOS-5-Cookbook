/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

CGPoint CGRectGetCenter(CGRect rect)
{
    CGPoint pt;
    pt.x = CGRectGetMidX(rect);
    pt.y = CGRectGetMidY(rect);
    return pt;
}

@interface TestBedViewController : UIViewController
{
    UIImageView *backObject;
    UIImageView *frontObject;
}
@end

@implementation TestBedViewController

- (void) swap: (id) sender
{
	self.navigationItem.rightBarButtonItem.enabled = NO;
	[UIView animateWithDuration:1.0f
					 animations:^{
						 frontObject.alpha = 0.0f;
						 backObject.alpha = 1.0f;
						 frontObject.transform = CGAffineTransformMakeScale(0.25f, 0.25f);
						 backObject.transform = CGAffineTransformIdentity;
						 [self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
					 }
					 completion:^(BOOL done){
                         UIImageView *tmp = frontObject;
                         frontObject = backObject;
                         backObject = tmp;
						 self.navigationItem.rightBarButtonItem.enabled = YES;
					 }];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Swap", @selector(swap:));
    
    // Create the back object, shrink and hide
	backObject = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BFlyCircle.png"]];
	backObject.transform = CGAffineTransformMakeScale(0.25f, 0.25f);
	backObject.alpha = 0.0f;
	[self.view addSubview:backObject];
	
	// Create the front object
	frontObject = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BFlyCircleMaroon.png"]];
	[self.view addSubview:frontObject];
}

- (void) viewDidAppear:(BOOL)animated
{
    frontObject.center = CGRectGetCenter(self.view.bounds);
    backObject.center = CGRectGetCenter(self.view.bounds);
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    frontObject.center = CGRectGetCenter(self.view.bounds);
    backObject.center = CGRectGetCenter(self.view.bounds);
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
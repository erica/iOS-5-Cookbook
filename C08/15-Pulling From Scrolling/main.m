/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "DragView.h"
#import "PullView.h"
#import "UIColor-Random.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define SIDE		(IS_IPAD ? 160.0f : 80.0f)
#define NUM_OBJECTS	10

@interface TestBedViewController : UIViewController
{
    UIScrollView *scrollView;
}
@end

@implementation TestBedViewController
// Remove all custom views from the layout area
- (void) clear
{
	for (UIView *view in self.view.subviews)
		if (view != scrollView) [view removeFromSuperview];
}

// Set the random contents of the scroll view
- (void) setColors
{
	float offset = 0.0f;
	for (int i = 0; i < NUM_OBJECTS; i++)
	{
		UIImage *image = randomBlockImage(SIDE, IS_IPAD ? 30.0f : 15.0f);
		PullView *pullView = [[PullView alloc] initWithImage:image];
		pullView.frame = CGRectMake(offset, 0.0f, SIDE, SIDE);
		[scrollView addSubview:pullView];
		
		offset += SIDE;
	}	
}

// Force an update of the scroll view elements
- (void) recolor
{
	for (UIView *view in scrollView.subviews)
		if ([[view class] isKindOfClass:[PullView class]])
			[view removeFromSuperview];
	
	[self setColors];
}

- (void) viewDidAppear: (BOOL) animated
{
    scrollView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, SIDE);
}

- (void) viewDidLayoutSubviews
{
    [self viewDidAppear:NO];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Clear", @selector(clear));
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Colors", @selector(recolor));
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
	scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	scrollView.contentSize = CGSizeMake(SIDE * NUM_OBJECTS, SIDE);
    [self.view addSubview:scrollView];   

	[self setColors];
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
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
     
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
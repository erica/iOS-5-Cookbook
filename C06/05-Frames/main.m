/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UIView-ViewFrameGeometry.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface TestBedViewController : UIViewController
{
    UISegmentedControl *segmentedControl;
    UIView *innerView;
    UIView *outerView;
}
@end

@implementation TestBedViewController

- (void) recenter
{
    innerView.center = outerView.midpoint;
    segmentedControl.selectedSegmentIndex = 2;
}

-(void) segmentAction: (UISegmentedControl *) sc
{
	switch ([sc selectedSegmentIndex])
	{
		case 0:
			innerView.top = 0.0f;
			break;
		case 1:
			innerView.bottom = outerView.height;
			break;
        case 2:
            innerView.center = outerView.midpoint;
            break;
		case 3:
			innerView.left = 0.0f;
			break;
		case 4:
			innerView.right = outerView.width;
			break;
		default:
			break;
	}
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self recenter];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;

    // Create movement buttons
	NSArray *buttonNames = [@"Top Bottom Center Left Right" componentsSeparatedByString:@" "];
	segmentedControl = [[UISegmentedControl alloc] initWithItems:buttonNames];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar; 
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.selectedSegmentIndex = 2;
	self.navigationItem.titleView = segmentedControl;
	
    CGRect appRect = (CGRect) {.size = [[UIScreen mainScreen] applicationFrame].size};

    CGFloat insetAmount = IS_IPAD ? 80.0f : 5.0f;
    outerView = [[UIView alloc] initWithFrame:CGRectInset(appRect, insetAmount, insetAmount)];
	outerView.backgroundColor = [UIColor lightGrayColor];
    outerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:outerView];
	
	innerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 80.0f)];
	innerView.right = outerView.width;
	innerView.bottom = outerView.height;
    [self recenter];
    
	innerView.backgroundColor = COOKBOOK_PURPLE_COLOR;    
	[outerView addSubview:innerView];
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
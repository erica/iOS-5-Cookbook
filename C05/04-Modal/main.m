/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD        (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#pragma mark Custom Modal View Controller
@interface ModalViewController : UIViewController
- (IBAction)done:(id)sender;
@end

@implementation ModalViewController
- (IBAction)done:(id)sender {[self dismissModalViewControllerAnimated:YES];}
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {return YES;}
@end

#pragma mark Primary Controller
@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController

- (void) action: (id) sender
{
    // Load info controller from storyboard
    NSString *sourceName = IS_IPAD ? @"Modal~iPad" : @"Modal~iPhone";
    UIStoryboard *sb = [UIStoryboard storyboardWithName:sourceName bundle:[NSBundle mainBundle]];
    UINavigationController *navController = [sb instantiateViewControllerWithIdentifier:@"infoNavigationController"];
    
    // Select the transition style
	int styleSegment = [(UISegmentedControl *)self.navigationItem.titleView selectedSegmentIndex];
	int transitionStyles[4] = {UIModalTransitionStyleCoverVertical, UIModalTransitionStyleCrossDissolve, UIModalTransitionStyleFlipHorizontal, UIModalTransitionStylePartialCurl};
	navController.modalTransitionStyle = transitionStyles[styleSegment];
	
	// Select the presentation style for iPad only
	if (IS_IPAD)
	{
		int presentationSegment = [(UISegmentedControl *)[[self.view subviews] lastObject] selectedSegmentIndex];
		int presentationStyles[3] = {UIModalPresentationFullScreen, UIModalPresentationPageSheet, UIModalPresentationFormSheet};
        
		if (navController.modalTransitionStyle == UIModalTransitionStylePartialCurl)
		{
			// Partial curl with any non-full screen presentation raises an exception
			navController.modalPresentationStyle = UIModalPresentationFullScreen;
			[(UISegmentedControl *)[[self.view subviews] lastObject] setSelectedSegmentIndex:0];
		}
		else 
			navController.modalPresentationStyle = presentationStyles[presentationSegment];
	}

    [self.navigationController presentModalViewController:navController animated:YES];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
    
    
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[@"Slide Fade Flip Curl" componentsSeparatedByString:@" "]];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	self.navigationItem.titleView = segmentedControl;
    
    if (IS_IPAD)
	{
		NSArray *presentationChoices = [NSArray arrayWithObjects:@"Full Screen", @"Page Sheet", @"Form Sheet", nil];
		UISegmentedControl *iPadStyleControl = [[UISegmentedControl alloc] initWithItems:presentationChoices];
		iPadStyleControl.segmentedControlStyle = UISegmentedControlStyleBar;
		iPadStyleControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        iPadStyleControl.center = CGPointMake(CGRectGetMidX(self.view.bounds), 22.0f);
		[self.view addSubview:iPadStyleControl];
	}
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
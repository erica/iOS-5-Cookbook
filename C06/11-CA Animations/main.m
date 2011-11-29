/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
}

- (void) animate: (id) sender
{
	// Set up the animation
	CATransition *animation = [CATransition animation];
	animation.delegate = self;
	animation.duration = 1.0f;
	animation.timingFunction = UIViewAnimationCurveEaseInOut;
	
	switch ([(UISegmentedControl *)self.navigationItem.titleView selectedSegmentIndex]) 
	{
		case 0:
			animation.type = kCATransitionFade;
			break;
		case 1:
			animation.type = kCATransitionMoveIn;
			break;
		case 2:
			animation.type = kCATransitionPush;
			break;
		case 3:
			animation.type = kCATransitionReveal;
		default:
			break;
	}
	animation.subtype = kCATransitionFromBottom;
	
	// Perform the animation
	[self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
	[self.view.layer addAnimation:animation forKey:@"animation"];
}

- (void) viewDidAppear: (BOOL) animated
{
	// Create the back object
	UIImageView *backObject = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BFlyCircle.png"]] autorelease];
	backObject.center = self.view.center;
	[self.view addSubview:backObject];
	
	// Create the front object
	UIImageView *frontObject = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BFlyCircleMaroon.png"]] autorelease];
	frontObject.center = self.view.center;
	[self.view addSubview:frontObject];
	
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Go", @selector(animate:));
	
	// Add a segmented control to select the animation
	UISegmentedControl *sc = [[UISegmentedControl alloc] initWithItems:[@"Fade Over Push Reveal" componentsSeparatedByString:@" "]];
	sc.segmentedControlStyle = UISegmentedControlStyleBar;
	sc. selectedSegmentIndex = 0;
	self.navigationItem.titleView = [sc autorelease];
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
	UINavigationController *nav;
}
@end
@implementation TestBedAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	nav = [[UINavigationController alloc] initWithRootViewController:[[[TestBedViewController alloc] init] autorelease]];
	[window addSubview:nav.view];
	[window makeKeyAndVisible];
}
- (void) dealloc
{
	[nav.view removeFromSuperview];	[nav release];	[window release];	[super dealloc];
}
@end
int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
	[pool release];
	return retVal;
}
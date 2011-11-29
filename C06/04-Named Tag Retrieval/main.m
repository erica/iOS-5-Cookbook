/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UIView-TagExtensions.h"
#import "UIView-NameExtensions.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define LABEL_TAG 101
#define SWITCH_TAG 102

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController

- (void) updateSwitch:(id)sender 
{
	// toggle the switch from its current setting
	UISwitch *s = [self.view.window switchNamed:@"my switch"];
	[s setOn:!s.isOn];
}

- (void) updateTime:(id)sender 
{
	// set the label to the current time
	[self.view.window labelNamed:@"my label"].text = [[NSDate date] description];
}

- (void) loadView
{
    self.view = [[[NSBundle mainBundle] loadNibNamed:@"View" owner:self options:NULL] lastObject];
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Switch", @selector(updateSwitch:));
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Time", @selector(updateTime:));
    
    // Uncomment for registered names
    // [[self.view viewWithTag:LABEL_TAG] registerName:@"my label"];
	// [[self.view viewWithTag:SWITCH_TAG] registerName:@"my switch"];
    
    // Uncomment for associated names
    [self.view viewWithTag:LABEL_TAG].nametag = @"my label";
    [self.view viewWithTag:SWITCH_TAG].nametag = @"my switch";
}

- (void) viewDidAppear: (BOOL) animated
{
	[self updateTime:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void) dealloc
{
    // Uncomment for associated names
    [self.view viewWithTag:LABEL_TAG].nametag = nil;
    [self.view viewWithTag:SWITCH_TAG].nametag = nil;
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
/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "KVCloudHelper.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

CGPoint CGRectGetCenter(CGRect rect);
CGPoint CGRectGetCenter(CGRect rect)
{
    CGPoint pt;
    pt.x = CGRectGetMidX(rect);
    pt.y = CGRectGetMidY(rect);
    return pt;
}

@interface TestBedViewController : UIViewController <NSFilePresenter>
{
    KVCloudHelper *helper;
    UISwitch *switchView;
    NSUbiquitousKeyValueStore *kv;
}
@end

@implementation TestBedViewController

#pragma mark initial sync
- (void) kvStorePerformedInitialSync
{
    NSLog(@"Initial sync. Refresh value from cloud.");
    switchView.on = [kv boolForKey:@"switchIsOn"];
}


#pragma mark kv store coordination
- (void) kvStoreUpdated
{
    NSLog(@"Switch updated from cloud");
    switchView.on = [kv boolForKey:@"switchIsOn"];
}

- (void) toggleSwitch: (UISwitch *) aSwitch
{
    // Send switch update out to cloud
    [kv setBool:aSwitch.isOn forKey:@"switchIsOn"];
    [kv synchronize];
}

- (void) startup
{
    // Establish helper
    helper = [[KVCloudHelper alloc] init];
    helper.delegate = self;
    
    kv = [NSUbiquitousKeyValueStore defaultStore];
    switchView.on = [kv boolForKey:@"switchIsOn"];
}

#pragma mark - initialization

- (void) viewDidAppear:(BOOL)animated
{
    switchView.center = CGRectGetCenter(self.view.bounds);
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    switchView.center = CGRectGetCenter(self.view.bounds);
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
   
    switchView = [[UISwitch alloc] init];
    [switchView addTarget:self action:@selector(toggleSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:switchView];
    
    [self startup];
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
    // [application setStatusBarHidden:YES];
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
/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface TestBedViewController : UIViewController
{
    UITextView *tv;
}
@end

@implementation TestBedViewController

- (void) loadView
{
    [super loadView];
    
	NSString *lorem = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent condimentum justo vestibulum nisl vestibulum sodales. Vestibulum dapibus sagittis elit, id facilisis eros ullamcorper at. Morbi consectetur tempor augue at convallis. Fusce diam leo, porta in mollis sed, molestie in dui. Proin accumsan ante id nunc mollis porttitor. Donec dapibus, nunc vitae consequat sollicitudin, justo enim consequat arcu, a hendrerit velit purus vitae erat. Sed a eros ac elit pulvinar aliquet nec sed quam. Nullam in elit nunc. Integer fringilla orci at enim feugiat et congue ipsum interdum. Mauris elit elit, egestas id fringilla vel, gravida ut orci. Sed mattis risus luctus orci auctor vitae hendrerit est consectetur.";
    
    tv = [[UITextView alloc] initWithFrame:self.view.frame];
    tv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tv];
    
    tv.font = [UIFont fontWithName:@"pirulen" size:IS_IPAD ? 28.0f : 12.0f];
	tv.text = lorem;
	tv.editable = NO;
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
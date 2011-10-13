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

typedef void (^AnimationBlock)(void);
typedef void (^CompletionBlock)(BOOL finished);

@interface TestBedViewController : UIViewController
{
	UIView *bounceView;
}
@end

@implementation TestBedViewController

- (void) bounce: (id) sender
{
	self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // Define the three stages of the animation in forward order
    AnimationBlock makeSmall = ^(void){
        bounceView.transform = CGAffineTransformMakeScale(0.01f, 0.01f);};
    AnimationBlock makeLarge = ^(void){
        bounceView.transform = CGAffineTransformMakeScale(1.15f, 1.15f);};
    AnimationBlock restoreToOriginal = ^(void) {
        bounceView.transform = CGAffineTransformIdentity;};
    
    // Create the three completion links in reverse order
    CompletionBlock reenable = ^(BOOL finished) {
        self.navigationItem.rightBarButtonItem = BARBUTTON(@"Start", @selector(bounce:));};
    CompletionBlock shrinkBack = ^(BOOL finished) {
        [UIView animateWithDuration:0.2f animations:restoreToOriginal completion: reenable];};   
    CompletionBlock bounceLarge = ^(BOOL finished){
        [UIView animateWithDuration:0.2 animations:makeLarge completion:shrinkBack];};

    // Start the animation
    [UIView animateWithDuration: 0.5f animations:makeSmall completion:bounceLarge];	
}

- (void) viewDidAppear:(BOOL)animated
{
    bounceView.center = CGRectGetCenter(self.view.bounds);
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    bounceView.center = CGRectGetCenter(self.view.bounds);
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Start", @selector(bounce:));
    
    bounceView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150.0f, 150.0f)];
	bounceView.backgroundColor = COOKBOOK_PURPLE_COLOR;
	[self.view addSubview:bounceView];
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
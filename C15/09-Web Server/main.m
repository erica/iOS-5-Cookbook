/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UIColor-Random.h"
#import "UIDevice-Reachability.h"
#import "WebHelper.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface TestBedViewController : UIViewController
{
    UIImageView *imageView;
    WebHelper *helper;
}
@end

@implementation TestBedViewController
#pragma mark -

- (UIImage *) image
{
    return imageView.image;
}

#pragma mark Tests
- (void) serviceCouldNotBeEstablished
{
	NSLog(@"Service could not be established. Sorry.");
}

- (void) serviceWasEstablished: (WebHelper *) aHelper
{    
    NSLog(@"Service was established!");
    NSString *hostname = [UIDevice currentDevice].hostname;
    
    NSLog(@"Connect to http://%@:%d", hostname, aHelper.chosenPort);
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Disconnect", @selector(disconnect));
    
    NSString *portString = [NSString stringWithFormat:@"Port %d", aHelper.chosenPort];
    self.title = portString;
}

- (void) serviceWasLost
{
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Start serving", @selector(serve));
	NSLog(@"Press the button to start serving");
}

- (void) serve
{
	self.navigationItem.rightBarButtonItem = nil;
    helper = [WebHelper serviceWithDelegate:self];
}

- (void) action: (id) sender
{
    UINavigationController *nav = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    if (IS_IPAD)
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentModalViewController:nav animated:YES];
}

- (UIImage *) createWithColor: (UIColor *) aColor
{
    CGRect rect = (CGRect){.size = CGSizeMake(320.0f, 320.0f)};
    UIGraphicsBeginImageContext(rect.size);
    [[UIColor whiteColor] set];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
    [aColor set];
    [[UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 40.0f, 40.0f) cornerRadius:32.0f] fill];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void) color
{
    imageView.image = [self createWithColor:[UIColor randomColor]];
}

#pragma mark -

#pragma mark Setup
- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    [self color];
    
    self.navigationItem.leftBarButtonItem = BARBUTTON(@"Color", @selector(color));
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Start Server", @selector(serve));
}

- (void) viewDidAppear:(BOOL)animated
{
    imageView.frame = self.view.frame;
}

- (void) viewDidLayoutSubviews
{
    [self viewDidAppear:NO];
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
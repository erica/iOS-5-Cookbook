/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UIDevice-Orientation.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface TestBedViewController : UIViewController
{
    UITextView *textView;
    NSMutableString *log;
}
@end

@implementation TestBedViewController

- (void) log: (NSString *) formatstring, ...
{
	if (!formatstring) return;
    
	va_list arglist;
	va_start(arglist, formatstring);
	NSString *outstring = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
    
    printf("%s\n", [outstring UTF8String]);

    if (!log) log = [NSMutableString string];
    [log insertString:@"\n" atIndex:0];
    [log insertString:outstring atIndex:0];
    textView.text = log;
}

- (void) tick
{
    float angle = [UIDevice currentDevice].orientationAngle;
    [self log:@"%0.1f", angle * 360 / (2 * M_PI)];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.editable = NO;
    textView.font = [UIFont fontWithName:@"Futura" size:IS_IPAD ? 24.0f : 12.0f];
    textView.textColor = COOKBOOK_PURPLE_COLOR;
    [self.view addSubview:textView];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(tick) userInfo:nil repeats:YES];
}

- (void) viewDidAppear:(BOOL)animated
{
    textView.frame = self.view.bounds;
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
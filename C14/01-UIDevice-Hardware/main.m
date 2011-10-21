/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UIDevice-Hardware.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define RESIZABLE(_VIEW_) [_VIEW_ setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth]
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

- (NSString *) commasForNumber: (long long) num
{
	if (num < 1000) return [NSString stringWithFormat:@"%d", num];
	return	[[self commasForNumber:num/1000] stringByAppendingFormat:@",%03d", (num % 1000)];
}

- (void) runTests
{
    self.title = @"UIDevice Tests";
    UIDevice *device = [UIDevice currentDevice];
    log = [NSMutableString string];
    
    NSString *separator = @"\n***\n";

    // Run tests
    [self log:@"Mac Address: %@", [device macaddress]];   
    [self log:@"Platform: %@, %@", [device platform], [device platformString]];
    [self log:@"Total memory: %@", [self commasForNumber:[device totalMemory]]];
    [self log:@"User memory: %@", [self commasForNumber:[device userMemory]]];
    [self log:@"Total disk space: %@", [self commasForNumber:[device totalDiskSpace].longLongValue]];
    [self log:@"Free disk space: %@", [self commasForNumber:[device freeDiskSpace].longLongValue]];
    [self log:separator];
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
    
    [self performSelector:@selector(runTests) withObject:nil afterDelay:3.0f];
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
/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <UIKit/UITextChecker.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface TestBedViewController : UIViewController
{
	UITextView *tv;
	UITextChecker *checker;
	int offset;
}
@end

@implementation TestBedViewController
- (void) nextMisspelling: (id) sender
{
	if (![tv isFirstResponder])
		[tv becomeFirstResponder];

	NSRange entireRange = NSMakeRange(0, tv.text.length);
	NSRange range = [checker rangeOfMisspelledWordInString:tv.text range:entireRange startingAt:offset wrap:YES language:@"en"];
    
	if (range.location != NSNotFound)
    {
		offset = range.location + range.length;
        tv.selectedRange = range;
    }
	else 
		offset = 0;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];    
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Next Misspelling", @selector(nextMisspelling:));
    
    tv = [[UITextView alloc] initWithFrame:self.view.bounds];
    tv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	tv.font = [UIFont fontWithName:@"Georgia" size:(IS_IPAD) ? 48.0f : 18.0f];
	[self.view addSubview:tv];
    
    tv.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent condimentum justo vestibulum nisl vestibulum sodales. Vestibulum dapibus sagittis elit, id facilisis eros ullamcorper at. Morbi consectetur tempor augue at convallis. Fusce diam leo, porta in mollis sed, molestie in dui. Proin accumsan ante id nunc mollis porttitor. Donec dapibus, nunc vitae consequat sollicitudin, justo enim consequat arcu, a hendrerit velit purus vitae erat. Sed a eros ac elit pulvinar aliquet nec sed quam. Nullam in elit nunc. Integer fringilla orci at enim feugiat et congue ipsum interdum. Mauris elit elit, egestas id fringilla vel, gravida ut orci. Sed mattis risus luctus orci auctor vitae hendrerit est consectetur.";
	tv.editable = YES;
    
    checker = [[UITextChecker alloc] init];
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
/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface NumberViewController : UIViewController
@property (nonatomic, assign) int number;
@property (nonatomic, strong, readonly) UITextView *textView;
+ (id) controllerWithNumber: (int) number;
@end

@implementation NumberViewController
@synthesize number, textView;

// Return a new view controller at the specified level number
+ (id) controllerWithNumber: (int) number
{
    NumberViewController *viewController = [[NumberViewController alloc] init];
    viewController.number = number;
    viewController.textView.text = [NSString stringWithFormat:@"Level %d", number];
    return viewController;
}

// Increment and push a controller onto the stack
- (void) pushController: (id) sender
{
    NumberViewController *nvc = [NumberViewController controllerWithNumber:number + 1];
    [self.navigationController pushViewController:nvc animated:YES];
}

// Set up the text and title
- (void) viewDidAppear: (BOOL) animated
{
    self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    
    // match the title to the text view
    self.title = self.textView.text; 
    self.textView.frame = self.view.frame;
    
    // Add a right bar button that pushes a new view
    if (number < 6)
        self.navigationItem.rightBarButtonItem = 
        BARBUTTON(@"Push", @selector(pushController:));
}

- (id) init
{
    if (!(self = [super init])) return self;
    
    textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.frame = [[UIScreen mainScreen] bounds];
    textView.font = [UIFont fontWithName:@"Futura" size:IS_IPAD ? 192.0f : 96.0f];
    textView.textAlignment = UITextAlignmentCenter;
    textView.editable = NO;
    textView.autoresizingMask = self.view.autoresizingMask;

    return self;
}

- (void) dealloc
{
    [textView removeFromSuperview];
    textView = nil;
}

// Create the view
- (void) loadView
{
    [super loadView];
    [self.view addSubview:textView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
    NumberViewController *nvc;
}
@end
@implementation TestBedAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    [application setStatusBarHidden:YES];
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	nvc = [NumberViewController controllerWithNumber:1];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:nvc];
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
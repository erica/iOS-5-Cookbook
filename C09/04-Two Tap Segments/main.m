/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

@class DoubleTapSegmentedControl;

@protocol DoubleTapSegmentedControlDelegate <NSObject>
- (void) performSegmentAction: (DoubleTapSegmentedControl *) aDTSC;
@end

@interface DoubleTapSegmentedControl : UISegmentedControl
@property (nonatomic, retain) id <DoubleTapSegmentedControlDelegate> delegate;
@end

@implementation DoubleTapSegmentedControl
@synthesize delegate;
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	if (self.delegate) [self.delegate performSegmentAction:self];
}
@end


@interface TestBedViewController : UIViewController  <DoubleTapSegmentedControlDelegate>
@end

@implementation TestBedViewController

- (void) performSegmentAction: (DoubleTapSegmentedControl *) seg
{
    NSArray *items = [@"One*Two*Three" componentsSeparatedByString:@"*"];
    NSString *selected = [items objectAtIndex:seg.selectedSegmentIndex];
    if ([selected isEqualToString:self.title])
        selected = [NSString stringWithFormat:@"%@ (again)", selected];
    self.title = selected;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray *items = [@"One*Two*Three" componentsSeparatedByString:@"*"];
    DoubleTapSegmentedControl *seg = [[DoubleTapSegmentedControl alloc] initWithItems:items];
    seg.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f);
    seg.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    seg.selectedSegmentIndex = 0;
    seg.delegate = self;
    [self.view addSubview:seg];
    
    self.title = @"One";
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
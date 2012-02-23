/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPHONE			(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

@interface TestBedViewController : UIViewController
{
    UIDatePicker *datePicker;
    UISegmentedControl *seg;
}
@end

@implementation TestBedViewController
- (void) update: (id) sender
{
    [datePicker setDate:[NSDate date]];
    datePicker.datePickerMode = seg.selectedSegmentIndex;
}

- (void) action: (id) sender
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	switch (seg.selectedSegmentIndex)
	{
		case 0:
			formatter.dateFormat = @"h:mm a";
			break;
		case 1:
			formatter.dateFormat = @"dd MMMM yyyy";
			break;
		case 2:
			formatter.dateFormat = @"MM/dd/YY h:mm a";
			break;
		case 3:
			formatter.dateFormat = @"HH:mm";
			break;
		default:
			break;
	}
	
	NSString *timestamp = [formatter stringFromDate:datePicker.date];
	NSLog(@"%@", timestamp);
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
    
    seg = [[UISegmentedControl alloc] initWithItems:[@"Time Date DT Count" componentsSeparatedByString:@" "]];
	seg.segmentedControlStyle = UISegmentedControlStyleBar;
	seg.selectedSegmentIndex = 0;
    [seg addTarget:self action:@selector(update:) forControlEvents:UIControlEventValueChanged];
	self.navigationItem.titleView = seg;
    
    datePicker = [[UIDatePicker alloc] init];
    [self.view addSubview:datePicker];
}

- (void) viewDidAppear:(BOOL)animated
{
    datePicker.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
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
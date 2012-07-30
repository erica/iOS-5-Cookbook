/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Geometry.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

#define CAPWIDTH    110.0f
#define INSETS      (UIEdgeInsets){0.0f, CAPWIDTH, 0.0f, CAPWIDTH}
#define BASEGREEN   [[UIImage imageNamed:@"green-out.png"] resizableImageWithCapInsets:INSETS]
#define ALTGREEN    [[UIImage imageNamed:@"green-in.png"] resizableImageWithCapInsets:INSETS]
#define BASERED     [[UIImage imageNamed:@"red-out.png"] resizableImageWithCapInsets:INSETS]
#define ALTRED      [[UIImage imageNamed:@"red-in.png"] resizableImageWithCapInsets:INSETS]

@interface TestBedViewController : UIViewController
{
    UIButton *button;
    BOOL isOn;
}
@end

@implementation TestBedViewController

- (void) toggleButton: (UIButton *) aButton
{
	if ((isOn = !isOn))
	{
		[button setBackgroundImage:BASEGREEN forState:UIControlStateNormal];
		[button setBackgroundImage:ALTGREEN forState:UIControlStateHighlighted];
	}
	else
	{
		[button setBackgroundImage:BASERED forState:UIControlStateNormal];
		[button setBackgroundImage:ALTRED forState:UIControlStateHighlighted];
	}
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];

    // Create a button sized to our art
	button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0.0f, 0.0f, 300.0f, 233.0f);
	
	// Set up the button aligment properties
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	// Set the font and color
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
	button.titleLabel.font = [UIFont boldSystemFontOfSize:24.0f];
	
	// Add action
	[button addTarget:self action:@selector(toggleButton:) forControlEvents: UIControlEventTouchUpInside];
    
	// Place the button into the view and initialize its art
	[self.view addSubview:button];
    [self toggleButton:button];
    
    // Let label handle carriage returns
	/* 
     button.titleLabel.font = [UIFont boldSystemFontOfSize:36.0f];
	[button setTitle:@"Lorem Ipsum Dolor Sit" forState: UIControlStateNormal];
	
	button.titleLabel.textAlignment = UITextAlignmentCenter;
	button.titleLabel.lineBreakMode = UILineBreakModeWordWrap;	
     */
}

- (void) viewDidAppear:(BOOL)animated
{
    button.center = CGRectGetCenter(self.view.bounds);
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
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    window.rootViewController = tbvc;
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
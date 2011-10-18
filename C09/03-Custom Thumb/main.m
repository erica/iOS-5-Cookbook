/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Geometry.h"
#import "Thumb.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

@interface TestBedViewController : UIViewController
{
    UISlider *slider;
    float previousValue;
}
@end

@implementation TestBedViewController

// Update the thumb images as needed
- (void) updateThumb: (UISlider *) aSlider
{
	// Only update the thumb when registering significant changes, i.e. 10%
	if ((slider.value < 0.98) && (ABS(slider.value - previousValue) < 0.1f)) return;
	
	// create a new custom thumb image and use it for the highlighted state
    UIImage *customimg = thumbWithLevel(slider.value);
	[slider setThumbImage: customimg forState: UIControlStateHighlighted];
	previousValue = slider.value;
}

// Expand the slider to accomodate the bigger thumb
- (void) startDrag: (UISlider *) aSlider
{
	slider.frame = CGRectInset(slider.frame, 0.0f, -30.0f);
}

// At release, shrink the frame back to normal
- (void) endDrag: (UISlider *) aSlider
{
    slider.frame = CGRectInset(slider.frame, 0.0f, 30.0f);
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Set global UISlider appearance attributes
    [[UISlider appearance] setMinimumTrackTintColor:[UIColor blackColor]];
    [[UISlider appearance] setMaximumTrackTintColor:[UIColor grayColor]];
    
    // Initialize slider settigns
	previousValue = -99.0f;
	
	// Create slider
	slider = [[UISlider alloc] initWithFrame:(CGRect){.size=CGSizeMake(200.0f, 40.0f)}];
    [slider setThumbImage:simpleThumb() forState:UIControlStateNormal];
	slider.value = 0.0f;
    	
	// Create the callbacks for touch, move, and release
	[slider addTarget:self action:@selector(startDrag:) forControlEvents:UIControlEventTouchDown];
	[slider addTarget:self action:@selector(updateThumb:) forControlEvents:UIControlEventValueChanged];
	[slider addTarget:self action:@selector(endDrag:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
	
	// Present the slider
	[self.view addSubview:slider];
	[self performSelector:@selector(updateThumb:) withObject:slider afterDelay:0.1f];
    
    // Appearance examples
    /*
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    UIBarButtonItem *hello = BARBUTTON(@"Hello", nil);
    UIBarButtonItem *world = BARBUTTON(@"World", nil);
    world.tintColor = [UIColor greenColor];

    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"Hello"];
    navigationItem.leftBarButtonItem = hello;
    navigationItem.rightBarButtonItem = world;
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:[UIColor purpleColor]];    
    
    UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, 44.0f)];
    [self.view addSubview:bar];
    bar.items = [NSArray arrayWithObject:navigationItem]; 
     */
}

- (void) viewDidAppear:(BOOL)animated
{
    slider.center = CGRectGetCenter(self.view.bounds);
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
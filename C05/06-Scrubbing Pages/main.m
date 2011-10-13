/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "BookController.h"

#define CRAYON_NAME(CRAYON)	[[CRAYON componentsSeparatedByString:@"#"] objectAtIndex:0]
#define CRAYON_COLOR(CRAYON) [self colorFromHexString:[[CRAYON componentsSeparatedByString:@"#"] lastObject]]
#define IS_IPHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

@interface TestBedViewController : UIViewController <BookControllerDelegate>
{
    NSArray *rawColors;
    BookController *bookController;
    UISlider *pageSlider;
    NSTimer *hiderTimer;
}
@end

@implementation TestBedViewController

#pragma mark Data Source
- (UIColor *) colorFromHexString: (NSString *) hexColor
{
	unsigned int red, green, blue;

	NSRange range = NSMakeRange(0, 2);
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
	range.location += 2; 
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
	range.location += 2; 
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
	
	return [UIColor colorWithRed:(float)(red/255.0f) 
                           green:(float)(green/255.0f) 
                            blue:(float)(blue/255.0f) 
                           alpha:1.0f];
}

- (UIViewController *) controllerWithColor: (UIColor *) color withName: (NSString *) name
{
    UIViewController *controller = [BookController rotatableViewController];
    controller.view = [[[NSBundle mainBundle] loadNibNamed:(IS_IPHONE ? @"Page-iPhone" : @"Page-iPad") owner:controller options:nil] lastObject];
    controller.view.backgroundColor = color;
    
    UILabel *colorLabel = (UILabel *)[controller.view viewWithTag:101];
    colorLabel.text = name;
    
    return controller;
}

- (id) viewControllerForPage: (int) pageNumber
{
    if (pageNumber > (rawColors.count - 1)) return nil;
    if (pageNumber < 0) return nil;
    
    NSString *rawString = [rawColors objectAtIndex:pageNumber];
    UIViewController *vc = [self controllerWithColor:CRAYON_COLOR(rawString) withName:CRAYON_NAME(rawString)];
    vc.view.tag = pageNumber;
    return vc;
}

- (void) moveToPage: (UISlider *) theSlider
{
    [hiderTimer invalidate];
    hiderTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(hideSlider:) userInfo:nil repeats:NO];
    [bookController moveToPage:(int) theSlider.value];
}

- (void) bookControllerDidTurnToPage: (NSNumber *) pageNumber
{
    pageSlider.value = pageNumber.intValue;
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    // Add page view controller as a child view, and do housekeeping
    [self addChildViewController:bookController];
    [self.view addSubview:bookController.view];
    [bookController didMoveToParentViewController:self];
    // self.view.gestureRecognizers = bookController.gestureRecognizers;
    
    [self.view addSubview:pageSlider];
}

// Hide the slider after the timer fires
- (void) hideSlider: (NSTimer *) aTimer
{
    [UIView animateWithDuration:0.3f animations:^(void){
        pageSlider.alpha = 0.0f;
    }];
    
    [hiderTimer invalidate];
    hiderTimer = nil;
}

// Present the slider when tapped
- (void) handleTap: (UIGestureRecognizer *) recognizer
{
    [UIView animateWithDuration:0.3f animations:^(void){
        pageSlider.alpha = 1.0f;
    }];
    
    [hiderTimer invalidate];
    hiderTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(hideSlider:) userInfo:nil repeats:NO];
}

- (void) loadView
{
    [super loadView];
    
    // Create background view
    CGRect appRect = [[UIScreen mainScreen] applicationFrame];
    self.view = [[UIView alloc] initWithFrame: appRect];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // Load colors and create first view controller
    NSString *pathname = [[NSBundle mainBundle]  pathForResource:@"crayons" ofType:@"txt" inDirectory:@"/"];
	rawColors = [[NSString stringWithContentsOfFile:pathname encoding:NSUTF8StringEncoding error:nil] 
                  componentsSeparatedByString:@"\n"];
    
    // Establish the page view controller
    bookController = [BookController bookWithDelegate:self];
    bookController.view.frame = (CGRect){.size = appRect.size};
    
    // Establish a slider
    float minSize = MIN(appRect.size.width, appRect.size.height);
    float sliderHeight = IS_IPHONE ? 40.0f : 80.0f;
    pageSlider = [[UISlider alloc] initWithFrame:CGRectMake(0.0f, 0.0f, minSize, sliderHeight)];
    [pageSlider addTarget:self action:@selector(moveToPage:) forControlEvents:UIControlEventValueChanged];

    pageSlider.alpha = 0.0f; // initially hidden
    pageSlider.center = CGPointMake(self.view.center.x, sliderHeight / 2.0f);
    pageSlider.minimumValue = 0.0f;
    pageSlider.maximumValue = (float)(rawColors.count - 1);
    pageSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    pageSlider.continuous = YES;
    pageSlider.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    pageSlider.minimumTrackTintColor = [UIColor grayColor];
    pageSlider.maximumTrackTintColor = [UIColor blackColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
    
    [self.view addSubview:pageSlider];
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
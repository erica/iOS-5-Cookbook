/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

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

- (void) doLog: (NSString *) formatstring, ...
{
    if (!formatstring) return;
    
    va_list arglist;
    va_start(arglist, formatstring);
    NSString *outstring = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
    va_end(arglist);
    
    if (!log) log = [NSMutableString string];
    
    NSLog(@"%@", outstring);
    
    [log appendString:outstring];
    [log appendString:@"\n"];
    textView.text = log;
}

- (void) reverseGeocode: (id) sender
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:37.33168400 longitude:-122.03075800];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!placemarks)
         {
             [self doLog:@"Error retrieving placemarks: %@", error.localizedFailureReason];
             return;
         }
         
         [self doLog:@"Placemarks from Location: %f, %f", location.coordinate.latitude, location.coordinate.longitude];
         for (CLPlacemark *placemark in placemarks)
         {
             [self doLog:@"%@", placemark.description];
         }         
     }];
    
}
- (void) geocode: (id) sender
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    NSString *address = @"1 Infinite Loop, Cupertino, CA 95014";
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!placemarks)
         {
             [self doLog:@"Error retrieving placemarks: %@", error.localizedFailureReason];
             return;
         }
         
         [self doLog:@"Placemarks from Description (%@):", address];
         for (CLPlacemark *placemark in placemarks)
         {
             [self doLog:@"%@", placemark.description];
         }         
     }];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Reverse", @selector(reverseGeocode:));
    self.navigationItem.leftBarButtonItem = BARBUTTON(@"Forward", @selector(geocode:));
    
    textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.font = [UIFont fontWithName:@"Futura" size: IS_IPAD ? 24.0f : 12.0f];
    textView.editable = NO;
    [self.view addSubview:textView];
}

#pragma mark -

- (void) viewDidAppear:(BOOL)animated
{
    textView.frame = self.view.bounds;
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
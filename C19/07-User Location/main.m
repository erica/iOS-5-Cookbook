/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface TestBedViewController : UIViewController <CLLocationManagerDelegate>
{
    MKMapView *mapView;
}
@end

@implementation TestBedViewController
// Search for n seconds to get the best location during that time
- (void) tick: (NSTimer *) timer
{
    self.title = @"Searching...";
	if (mapView.userLocation)
    {
        // Check for valid coordinate
        CLLocationCoordinate2D coord = mapView.userLocation.location.coordinate;
        if (!coord.latitude && !coord.longitude) return;
        
        // Update titles
        self.title = @"Found!";
		[mapView setRegion:MKCoordinateRegionMake(coord, MKCoordinateSpanMake(0.005f, 0.005f)) animated:NO];
        mapView.userLocation.title = @"Location Coordinates";
        mapView.userLocation.subtitle = [NSString stringWithFormat:@"%f, %f", coord.latitude, coord.longitude];
        
        // Attempt to retrieve placemarks
        NSLog(@"Placemarks from Location: %f, %f", coord.latitude, coord.longitude);        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:mapView.userLocation.location completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if (!placemarks)
             {
                 NSLog(@"Error retrieving placemarks: %@", error.localizedFailureReason);
                 return;
             }

             for (CLPlacemark *placemark in placemarks)
                 NSLog(@"%@", placemark.description);
         }];
    }
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Add map
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 320.0f)];
    mapView.showsUserLocation = YES;
    mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
    [self.view addSubview:mapView];
    
	if (!CLLocationManager.locationServicesEnabled)
	{
		NSLog(@"User has opted out of location services");
		return;
	}
	else 
	{
        [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(tick:) userInfo:nil repeats:YES];
	}
}

#pragma mark -

- (void) viewDidAppear:(BOOL)animated
{
    mapView.frame = self.view.bounds;
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
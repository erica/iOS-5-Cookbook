/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

/*
 
 Compile and deploy to device only.
 Will not link on Sim with VoiceServices
 
 */

@interface TestBedViewController : UIViewController <CLLocationManagerDelegate>
{
    UITextView *textView;
    NSMutableString *log;
    CLLocationManager *locManager;
    
    NSObject *vs; // Not for use in App Store apps
    NSDate *lockout;
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

- (void) report: (NSString *) aString
{
	// Only allow this method to run every five seconds
	if (!lockout) 
		lockout = [NSDate dateWithTimeIntervalSinceNow:5.0f];
	else if ([[NSDate date] timeIntervalSinceDate:lockout] < 0.0f) 
        return;

    lockout = [NSDate dateWithTimeIntervalSinceNow:5.0f];
	
	// DO NOT USE THIS IN APP STORE APPLICATIONS
	[vs performSelector:@selector(startSpeakingString:) withObject:aString];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self doLog:@"Location manager error: %@", error.localizedFailureReason];
    return;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	if (newLocation.speed > 0.0f)
	{
		NSString *speedFeedback = [NSString stringWithFormat:@"Speed is %0.1f miles per hour", 2.23693629 * newLocation.speed];
		[self report:speedFeedback];
		[self doLog:speedFeedback];
	}
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
   
    textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.font = [UIFont fontWithName:@"Futura" size: IS_IPAD ? 24.0f : 12.0f];
    textView.editable = NO;
    [self.view addSubview:textView];
    
    if (!CLLocationManager.locationServicesEnabled)
    {
        [self doLog:@"User has opted out of location services"];
        return;
    }
    
    locManager = [[CLLocationManager alloc] init];
    locManager.delegate = self;
    locManager.desiredAccuracy = kCLLocationAccuracyBest;
    locManager.distanceFilter = 5.0f; // in meters
    [locManager startUpdatingLocation];
    
    [self doLog:@"Starting up..."];

    // DO NOT USE THIS IN YOUR APPLICATIONS!
    vs = [[NSClassFromString(@"VSSpeechSynthesizer") alloc] init];
    [self performSelector:@selector(report:) withObject:@"Ready to go" afterDelay:1.0f];
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
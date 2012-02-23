/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UIView-NameExtensions.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface TestBedViewController : UIViewController
@property (nonatomic, strong) UITextView *textView;
@end

@implementation TestBedViewController
@synthesize textView;

// Basic status
NSString *pushStatus ()
{
	return [[UIApplication sharedApplication] enabledRemoteNotificationTypes] ?
        @"Notifications were active for this application" :
        @"Remote notifications were not active for this application";
}

// Fetch the current switch settings
- (NSUInteger) switchSettings
{
	NSUInteger settings = 0;
    if ([self.view switchNamed:@"BadgeSwitch"].isOn) settings = settings | UIRemoteNotificationTypeBadge;
    if ([self.view switchNamed:@"AlertSwitch"].isOn) settings = settings | UIRemoteNotificationTypeAlert;
    if ([self.view switchNamed:@"SoundSwitch"].isOn) settings = settings | UIRemoteNotificationTypeSound;
    return settings;
}

// Change the switches to match reality
- (void) updateSwitches
{
	NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
	[self.view switchNamed:@"BadgeSwitch"].on = (rntypes & UIRemoteNotificationTypeBadge);
    [self.view switchNamed:@"AlertSwitch"].on = (rntypes & UIRemoteNotificationTypeAlert);
    [self.view switchNamed:@"SoundSwitch"].on = (rntypes & UIRemoteNotificationTypeSound);
}

// Little hack work-around to catch the end when the confirmation dialog goes away
- (void) confirmationWasHidden: (NSNotification *) notification
{
	// A secondary registration helps work through early 3.0 beta woes. It costs nothing and has no
	// ill side effects, so can be used without worry.
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:[self switchSettings]];
	[self updateSwitches];
}

// Register application for the services set out by the switches
- (void) registerServices
{
	if (![self switchSettings])
	{
		textView.text = [NSString stringWithFormat:@"%@\nNothing to register. Skipping.\n(Did you mean to press Unregister instead?)", pushStatus()];
		[self updateSwitches];
		return;
	}
    
	NSString *status = [NSString stringWithFormat:@"%@\nAttempting registration", pushStatus()];
	textView.text = status;
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:[self switchSettings]];
}

// Unregister application for all push notifications
- (void) unregisterServices
{
	NSString *status = [NSString stringWithFormat:@"%@\nUnregistering.", pushStatus()];
	textView.text = status;
	
	[[UIApplication sharedApplication] unregisterForRemoteNotifications];
	[self updateSwitches];
}


- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(confirmationWasHidden:) name:@"UIApplicationDidBecomeActiveNotification" object:nil];
    
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Register", @selector(registerServices));
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Unregister", @selector(unregisterServices));
}

#pragma mark - Setup

- (void) viewDidAppear:(BOOL)animated
{
    if (!textView)
    {
        textView = [[UITextView alloc] initWithFrame:self.view.bounds];
        textView.editable = NO;
        textView.font = [UIFont fontWithName:@"Futura" size:IS_IPAD ? 28.0f : 14.0f];
        [self.view addSubview:textView];
    }
    textView.frame = self.view.bounds;
    
    float vOffset = 30.0f;
    float height = self.view.bounds.size.height;
    
    NSArray *labelText = [@"Badge*Alert*Sound" componentsSeparatedByString:@"*"];
    for (NSString *eachLabelText in labelText)
    {
        NSString *switchText = [eachLabelText stringByAppendingString:@"Switch"];

        if (![self.view viewNamed:eachLabelText])
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 40.0f)];
            label.textAlignment = UITextAlignmentRight;
            label.font = [UIFont fontWithName:@"Futura" size: 24.0f];
            label.text = eachLabelText;
            label.nametag = eachLabelText;
            label.textColor = COOKBOOK_PURPLE_COLOR;
            [self.view addSubview:label];
            
            UISwitch *theswitch = [[UISwitch alloc] init];
            theswitch.nametag = switchText;
            [self.view addSubview:theswitch];
        }
        
        [self.view viewNamed:eachLabelText].center = CGPointMake(50.0f, height - vOffset);
        [self.view viewNamed:switchText].center = CGPointMake(150.0f, height - vOffset);
        vOffset += 40.0f;
    }
    
    [self updateSwitches];
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
    TestBedViewController *tbvc;
}
@end
@implementation TestBedAppDelegate
// Retrieve the device token
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
	NSString *results = [NSString stringWithFormat:@"Badge: %@, Alert:%@, Sound: %@",
						 (rntypes & UIRemoteNotificationTypeBadge) ? @"Yes" : @"No", 
						 (rntypes & UIRemoteNotificationTypeAlert) ? @"Yes" : @"No",
						 (rntypes & UIRemoteNotificationTypeSound) ? @"Yes" : @"No"];
    
    NSLog(@"Enabled notification types: %d", rntypes);
	
	NSString *status = [NSString stringWithFormat:@"%@\nRegistration succeeded.\n\nDevice Token: %@\n%@", pushStatus(), deviceToken, results];
	tbvc.textView.text = status;
	NSLog(@"deviceToken: %@", deviceToken);
    [deviceToken.description writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/DeviceToken.txt"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Error registering for remote notifications: %@", error.localizedFailureReason);
    NSString *status = [NSString stringWithFormat:@"%@\nRegistration failed.\n\nError: %@", pushStatus(), error.localizedFailureReason];
    tbvc.textView.text = status;
}

// Handle an actual notification
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	NSString *status = [NSString stringWithFormat:@"Notification received:\n%@", userInfo.description];
    tbvc.textView.text = status;
    NSLog(@"%@", userInfo);
}

- (void) showString: (NSString *) aString
{
    tbvc.textView.text = aString;
}

// Report the notification payload when launched by alert
- (void) launchNotification: (NSNotification *) notification
{
    // This is a workaround to allow the text view to be created if needed first
	[self performSelector:@selector(showString:) withObject:[[notification userInfo] description] afterDelay:1.0f];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    // [application setStatusBarHidden:YES];
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	tbvc = [[TestBedViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
    window.rootViewController = nav;
	[window makeKeyAndVisible];
    
    // Listen for remote notification launches
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(launchNotification:) name:@"UIApplicationDidFinishLaunchingNotification" object:nil];
    
    NSLog(@"Launch options: %@", launchOptions);

    return YES;
}
@end
int main(int argc, char *argv[]) {
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
        return retVal;
    }
}
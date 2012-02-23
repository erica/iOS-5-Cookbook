/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "CloudHelper.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface TestBedViewController : UIViewController
{
}
@end

@implementation TestBedViewController

- (void) list: (id) sender
{
    NSLog(@"Contents of Documents: %@", [CloudHelper contentsOfUbiquityDocumentsFolder]);
}

- (void) create: (id) sender
{
    // Write to default container
    NSError *error;
    NSURL *targetURL = [CloudHelper ubiquityDocumentsFileURL:@"MyFirstFile.txt"];
    
    // Write a "Hello World" Text file to the cloud
    NSLog(@"About to write to file.");
    if (![@"Hello from the cloud!" writeToURL:targetURL atomically:YES encoding:NSUTF8StringEncoding error:nil])
    {
        NSLog(@"Error writing to %@: %@", targetURL, error.localizedFailureReason);
        return;
    }
    
    // Retrieve a URL to share
    NSDate __autoreleasing *date;
    NSURL *url = [[NSFileManager defaultManager] URLForPublishingUbiquitousItemAtURL:targetURL expirationDate:&date error:&error];
    if (!url)
        NSLog(@"Error creating publishing URL: %@", error.localizedFailureReason);
    else
    {
        NSLog(@"URL: %@", url);
        NSLog(@"Expires: %@", date);
    }
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"List", @selector(list:));
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Create", @selector(create:));
    
    // Default Ubiquity Container
    NSLog(@"Data: %@", [CloudHelper ubiquityDataURL]);
    
    // Shared Ubiquity Container
    NSString *sharedIdentifier = [CloudHelper containerize:@"com.sadun.SharedStorage"];
    NSLog(@"Shared: %@", [CloudHelper ubiquityDataURLForContainer:sharedIdentifier]);
    
    // Nonexistent Ubiquity Container
    NSString *nonexistentIdentifier = [CloudHelper containerize:@"com.sadun.nonexistent"];
    NSLog(@"Nonexistent: %@", [CloudHelper ubiquityDataURLForContainer:nonexistentIdentifier]);
    
    BOOL success = [CloudHelper setupUbiquityDocumentsFolder];
    if (success)
        NSLog(@"Default ubiquity Documents folder is ready"); 
    else
    {
        NSLog(@"Error setting up ubiquitous documents folder");
        return;
    }    
}

- (void) viewDidAppear:(BOOL)animated
{
    // someView.frame = self.view.bounds;
    // someView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
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
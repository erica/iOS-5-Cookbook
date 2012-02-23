/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface TestBedViewController : UIViewController <UITextViewDelegate>
{
    UITextView *textView;
}
@end

@implementation TestBedViewController

- (void) buildItems
{
    // Define the paths
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *testFolderPath = [documentsPath stringByAppendingPathComponent:@"TestFolder"];
    NSString *filePath1 = [testFolderPath stringByAppendingPathComponent:@"Hello.txt"];
    NSString *filePath2 = [documentsPath stringByAppendingPathComponent:@"Hello.txt"];
    
    NSError *error;
    BOOL success;

    // Create a folder
    if (![[NSFileManager defaultManager] fileExistsAtPath:testFolderPath])
    {
        success = [[NSFileManager defaultManager] createDirectoryAtPath:testFolderPath withIntermediateDirectories:NO attributes:nil error:&error];
        if (!success)
        {
            NSLog(@"Error creating test folder: %@", error.localizedFailureReason);
            return;
        }
    }
    
    // Now put a file there
    success = [@"Hello world\n" writeToFile:filePath1 atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!success)
    {
        NSLog(@"Error writing file 1: %@", error.localizedFailureReason);
        return;
    }
    
    // Put a file into the main Documents folder too
    success = [@"Hello world\n" writeToFile:filePath2 atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!success)
    {
        NSLog(@"Error writing file 2: %@", error.localizedFailureReason);
        return;
    }
    
    NSLog(@"Success. Files and folder created.");
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.font = [UIFont fontWithName:@"Futura" size: IS_IPAD ? 32.0f : 16.0f];
    textView.delegate = self;
    [self.view addSubview:textView];
    
    [self buildItems];
}

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
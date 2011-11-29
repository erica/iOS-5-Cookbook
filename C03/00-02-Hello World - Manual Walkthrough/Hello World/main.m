/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

// Simple macro distinguishes iPhone from iPad
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow *window;
}
@end

@implementation TestBedAppDelegate
- (UIViewController *) helloController
{
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor greenColor];
 
    // Add a basic label that says "Hello World"
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, window.bounds.size.width, 80.0f)];
    label.text = @"Hello World";
    label.center = CGPointMake(CGRectGetMidX(window.bounds), CGRectGetMidY(window.bounds));
    label.textAlignment = UITextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize: IS_IPHONE ? 32.0f : 64.0f];
    label.backgroundColor = [UIColor clearColor];
    [vc.view addSubview:label];    
    
    return vc;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	window.rootViewController = [self helloController];
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
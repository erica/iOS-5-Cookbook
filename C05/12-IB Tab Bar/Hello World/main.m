/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

@interface Hello_WorldAppDelegate : NSObject <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@end

@implementation Hello_WorldAppDelegate
@synthesize window = _window;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self.window makeKeyAndVisible];
    return YES;
}
@end

int main(int argc, char *argv[])
{
    int retVal = 0;
    @autoreleasepool {
        retVal = UIApplicationMain(argc, argv, nil, @"Hello_WorldAppDelegate");
    }
}

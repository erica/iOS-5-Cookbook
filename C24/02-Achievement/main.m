/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "ModalAlertDelegate.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define RECTCENTER(rect) CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define GKBEGINNER   @"com.sadun.cookbook.amazonian"

@interface TestBedViewController : UIViewController <GKAchievementViewControllerDelegate, UINavigationControllerDelegate>
{
    GKLocalPlayer *player;
}
@end

@implementation TestBedViewController

- (void) unlockAchievement
{
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier: GKBEGINNER];
    if (achievement)
    {
        achievement.percentComplete = 100.0f;
        achievement.showsCompletionBanner = YES;
        [achievement reportAchievementWithCompletionHandler:^(NSError *error)
         {
             if (error)
             {
                 NSLog(@"Error reporting achievement: %@", error.localizedFailureReason);
                 return;
             }

             self.navigationItem.rightBarButtonItem = BARBUTTON(@"Reset", @selector(resetAchievements));
         }];
    }
}

- (void) resetAchievements
{
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
    {
        if (error)
        {
            NSLog(@"Error resetting achievements: %@", error.localizedFailureReason);
            return;
        }
        
        self.navigationItem.rightBarButtonItem = BARBUTTON(@"Unlock", @selector(unlockAchievement));
    }];
}

- (void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void) showAchievements
{
    GKAchievementViewController *achievementController = [[GKAchievementViewController alloc] init];
    if (achievementController)
    {
        achievementController.achievementDelegate = self;
        [self presentModalViewController:achievementController animated:YES];
    }
}

- (void) checkAchievement
{
    // Default to unlock
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Unlock", @selector(unlockAchievement));

    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        if (error)
        {
            NSLog(@"Error loading achievements: %@", error.localizedFailureReason);
            return;
        }
        
        for (GKAchievement *achievement in achievements)
        {
            NSLog(@"Achievement: %@ : %f", achievement.identifier, achievement.percentComplete);
            if ([achievement.identifier isEqualToString:GKBEGINNER])
                self.navigationItem.rightBarButtonItem = BARBUTTON(@"Reset", @selector(resetAchievements));
        }
    }];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = BARBUTTON(@"Peek", @selector(showAchievements));
    
    player = [GKLocalPlayer localPlayer];
    if (player && !player.authenticated)
    {
        [player authenticateWithCompletionHandler:^(NSError *error){
            if (error)
            {
                NSLog(@"Error authenticating: %@", error.localizedFailureReason);
                return;
            }
            
            // authenticated.
            [self checkAchievement];
        }];
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
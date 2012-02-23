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

#define GKCATEGORY    @"com.sadun.cookbook.topPoints"

@interface TestBedViewController : UIViewController <GKLeaderboardViewControllerDelegate>
{
    GKLocalPlayer *player;
}
@end

@implementation TestBedViewController

- (NSNumber *) requestScore
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter your score" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    ModalAlertDelegate *delegate = [ModalAlertDelegate delegateWithAlert:alert];
    int response = [delegate show];
    if (!response) return nil;
    
    NSUInteger score = [[[alert textFieldAtIndex:0] text] intValue];
    return [NSNumber numberWithInt:score];
}

- (void) createScore: (id) sender
{
    // Fetch a "score"
    NSNumber *userScore = [self requestScore];
    if (!userScore) return;
    
    GKScore *score = [[GKScore alloc] initWithCategory:GKCATEGORY];
    score.value = userScore.intValue;
    [score reportScoreWithCompletionHandler:^(NSError *error){
        if (error)
        {
            NSLog(@"Error submitting score to game center: %@", error.localizedFailureReason);
            return;
        }
        
        NSLog(@"Success. Score submitted.");
    }];
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void) showLeaderboard
{
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    leaderboardController.category = GKCATEGORY;
    if (leaderboardController)
    {
        leaderboardController.leaderboardDelegate = self;
        [self presentModalViewController: leaderboardController animated: YES];
    }
}

- (void) peekAtLeaderboardForCategory: (NSString *) category
{
    GKLeaderboard *leaderBoard = [[GKLeaderboard alloc] init];
    leaderBoard.category = category;
    leaderBoard.range = NSMakeRange(1, 10); // top ten scores. Default range is 1,25
    leaderBoard.timeScope = GKLeaderboardTimeScopeWeek; // Within last week
    
    [leaderBoard loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error){
        if (error)
        {
            NSLog(@"Error retrieving leaderboard scores: %@", error.localizedFailureReason);
            return;
        }

        NSMutableArray *array = [NSMutableArray array];
        for (GKScore *score in scores)
            [array addObject:score.playerID];
        
        [GKPlayer loadPlayersForIdentifiers:array withCompletionHandler:^(NSArray *players, NSError *error){
            if (error)
            {
                // Report only with player ids
                for (GKScore *score in scores)
                    NSLog(@"[%2d] %@: %@ (%@)", score.rank, score.playerID, score.formattedValue, score.date);
                return;
            }
            for (int i = 0; i < scores.count; i++)
            {
                // Report with actual player names
                GKPlayer *aPlayer = [players objectAtIndex:i];
                GKScore *score = [scores objectAtIndex:i];
                NSLog(@"[%2d] %@: %@ (%@)", score.rank, aPlayer.alias, score.formattedValue, score.date);
            }
        }];
    }];
}

- (void) peekAtLeaderboards
{
    [self showLeaderboard];
    
    [GKLeaderboard loadCategoriesWithCompletionHandler:^(NSArray *categories, NSArray *titles, NSError *error)
     {
         if (error)
         {
             NSLog(@"Error retrieving leaderboard categories: %@", error.localizedFailureReason);
             return;
         }
         
         for (int i = 0; i < categories.count; i++)
         {
             NSString *category = [categories objectAtIndex:i];
             NSString *title = [titles objectAtIndex:i];
             NSLog(@"%@ : %@", category, title);
             
             [self peekAtLeaderboardForCategory:category];
         }
     }];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = BARBUTTON(@"Peek", @selector(peekAtLeaderboards));
    
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
            self.navigationItem.rightBarButtonItem = BARBUTTON(@"Score", @selector(createScore:));            
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
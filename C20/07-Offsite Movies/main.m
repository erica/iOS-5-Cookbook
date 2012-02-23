/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

// Large Movie (35 MB)
#define LARGE_URL @"http://www.archive.org/download/BettyBoopCartoons/Betty_Boop_More_Pep_1936_512kb.mp4"

// Short movie (3 MB)
#define SMALL_URL @"http://www.archive.org/download/Drive-inSaveFreeTv/Drive-in--SaveFreeTv_512kb.mp4"

@interface TestBedViewController : UIViewController
{
    UISegmentedControl *seg;
    MPMoviePlayerController *movieController;
}
@end

@implementation TestBedViewController
#pragma mark -
-(void)myMovieFinishedCallback:(NSNotification*)aNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [movieController.view removeFromSuperview];
    movieController = nil;
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Go", @selector(Play));
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void) playMovie
{
    self.navigationItem.rightBarButtonItem = nil;
    seg.enabled = NO;
    self.view.backgroundColor = [UIColor blackColor];
    
    NSArray *items = [NSArray arrayWithObjects: SMALL_URL, LARGE_URL, nil];
    NSString *whichItem = [items objectAtIndex:seg.selectedSegmentIndex];
    NSURL *sourceURL = [NSURL URLWithString:whichItem];
    
    movieController = [[MPMoviePlayerController alloc] initWithContentURL:sourceURL];
	movieController.view.frame = [[UIScreen mainScreen] bounds];
    movieController.controlStyle = MPMovieControlStyleFullscreen;
	[self.navigationController.view addSubview:movieController.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:movieController];
    
    [movieController play];
}

#pragma mark -

#pragma mark Setup
- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Play", @selector(playMovie));
    
    // Allow user to pick short or long data
    NSArray *items = [@"Short Long" componentsSeparatedByString:@" "];
	seg = [[UISegmentedControl alloc] initWithItems:items];
	seg.selectedSegmentIndex = 0;
	seg.segmentedControlStyle = UISegmentedControlStyleBar;
	self.navigationItem.titleView = seg;
}

- (void) viewDidAppear:(BOOL)animated
{
    movieController.view.frame = self.navigationController.view.bounds;
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
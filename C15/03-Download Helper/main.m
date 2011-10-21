/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "DownloadHelper.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define BUNNY_URL_STRING	@"http://players.edgesuite.net/videos/big_buck_bunny/bbb_448x252.mp4"
#define DEST_PATH   [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Bunny.mp4"]

@interface TestBedViewController : UIViewController <DownloadHelperDelegate>
{
    UITextView *textView;
    NSMutableString *log;
    DownloadHelper *helper;
    UIProgressView *progress;
    
    MPMoviePlayerController *movieController;
}
- (void) log: (NSString *) formatstring, ...;
@end

@implementation TestBedViewController
#pragma mark -
- (void) downloadFinished
{
    self.title = @"Download Complete";
    movieController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:DEST_PATH]];
	movieController.view.frame = self.view.bounds;
	[self.view addSubview:movieController.view];
    [movieController play];
}

- (void) dataDownloadFailed: (NSString *) reason
{
    self.title = @"Download Failed";
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Go", @selector(go));
}

- (void) downloadReceivedData
{
    float received = helper.bytesRead;
    float expected = helper.expectedLength;
    
    progress.progress = received / expected;
}

- (void) go
{
    self.navigationItem.rightBarButtonItem = nil;

    // Remove any existing data
    if ([[NSFileManager defaultManager] fileExistsAtPath:DEST_PATH])
        [[NSFileManager defaultManager] removeItemAtPath:DEST_PATH error:nil];
    
    helper = [DownloadHelper download:BUNNY_URL_STRING withTargetPath:DEST_PATH withDelegate:self];
    
    progress.progress = 0.0f;
}

#pragma mark -

#pragma mark Setup
- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.editable = NO;
    textView.font = [UIFont fontWithName:@"Futura" size:IS_IPAD ? 24.0f : 12.0f];
    textView.textColor = COOKBOOK_PURPLE_COLOR;
    [self.view addSubview:textView];
    
    log = [NSMutableString string];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Go", @selector(go));
    
    progress = [[UIProgressView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:progress];
}

- (void) log: (NSString *) formatstring, ...
{
	if (!formatstring) return;
    
	va_list arglist;
	va_start(arglist, formatstring);
	NSString *outstring = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
    
    printf("%s\n", [outstring UTF8String]);
    
    if (!log) log = [NSMutableString string];
    [log insertString:@"\n" atIndex:0];
    [log insertString:outstring atIndex:0];
    textView.text = log;
}

- (void) viewDidAppear:(BOOL)animated
{
    textView.frame = self.view.bounds;
    progress.frame = CGRectInset(self.view.frame, 80.0f, 80.0f);
    movieController.view.frame = self.view.bounds;
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
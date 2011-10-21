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

#define DATA_URL_STRING	@"http://players.edgesuite.net/videos/big_buck_bunny/bbb_448x252.mp4"

@interface TestBedViewController : UIViewController <NSURLConnectionDownloadDelegate>
{
    NSURLConnection *connection;    
    UIProgressView *progress;  
}
@end

@implementation TestBedViewController
#pragma mark -

- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes
{
    float percent = (float) totalBytesWritten / (float) expectedTotalBytes;

    // Perform GUI update on main thread
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
        progress.progress = percent;
    }];
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL
{
    if (!destinationURL)
    {
        self.title = @"Download Failed";
        return;
    }
    
    // This is broken as of Summer 2011.
    NSLog(@"Theoretically downloaded to: %@", destinationURL);    
}

- (void) go
{
    self.navigationItem.rightBarButtonItem = nil;

    progress.progress = 0.0f;
    
    NSURL *url = [NSURL URLWithString:DATA_URL_STRING];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark -

#pragma mark Setup
- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Go", @selector(go));
    
    progress = [[UIProgressView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:progress];
}

- (void) viewDidAppear:(BOOL)animated
{
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
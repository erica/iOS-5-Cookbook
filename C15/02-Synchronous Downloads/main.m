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

// Wrong URL
#define FAKE_URL @"http://www.idontbelievethisisavalidurlforthisexample.com"

#define DEST_PATH	[NSHomeDirectory() stringByAppendingString:@"/Documents/Movie.mp4"]

@interface TestBedViewController : UIViewController
{
    UITextView *textView;
    NSMutableString *log;
    BOOL success;

    UISegmentedControl *seg;
    MPMoviePlayerController *movieController;
}
- (void) log: (NSString *) formatstring, ...;
@end

@implementation TestBedViewController
#pragma mark -
-(void)myMovieFinishedCallback:(NSNotification*)aNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [movieController.view removeFromSuperview];
    movieController = nil;
}

- (void) downloadFinished
{
    // Restore GUI
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Go", @selector(go));
    seg.enabled = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    if (!success)
    {
        [self log:@"Failed download"];
        return;
    }   
    
    // Play the movie
    movieController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:DEST_PATH]];
	movieController.view.frame = self.view.bounds;
    movieController.controlStyle = MPMovieControlStyleFullscreen;
	[self.view addSubview:movieController.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:movieController];

    [movieController play];
}

- (void) getData: (NSURL *) url
{
	[self log:@"Starting download"];
    
    NSDate *startDate = [NSDate date];

	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
	NSURLResponse *response;
	NSError *error;
    success = NO;
    
	NSData* result = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
        
    if (!result)
    {
		[self log:@"Download error: %@", [error localizedFailureReason]];
        return;
    }
    
    if ((response.expectedContentLength == NSURLResponseUnknownLength) ||
        (response.expectedContentLength < 0))
    {
		[self log:@"Download error."];
        return;
    }
    
    if (![response.suggestedFilename isEqualToString:url.path.lastPathComponent])
    {
        [self log:@"Name mismatch. Probably carrier error page"];
        return;
    }

    if (response.expectedContentLength != result.length)
    {
        [self log:@"Got %d bytes, expected %d", result.length, response.expectedContentLength];
        return;
    }

    success = YES;
    [self log:@"Read %d bytes", result.length];
    [result writeToFile:DEST_PATH atomically:YES];
    [self log:@"Data written to file: %@.", DEST_PATH];
    [self log:@"Response suggested file name: %@", response.suggestedFilename];
    [self log:@"Elapsed time: %0.2f seconds.", [[NSDate date] timeIntervalSinceDate:startDate]];
}

- (void) go
{
    self.navigationItem.rightBarButtonItem = nil;
    seg.enabled = NO;
    
    NSArray *items = [NSArray arrayWithObjects: SMALL_URL, LARGE_URL, FAKE_URL, nil];
    NSString *whichItem = [items objectAtIndex:seg.selectedSegmentIndex];
    NSURL *sourceURL = [NSURL URLWithString:whichItem];

    // Remove any existing data
    if ([[NSFileManager defaultManager] fileExistsAtPath:DEST_PATH])
        [[NSFileManager defaultManager] removeItemAtPath:DEST_PATH error:nil];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[[NSOperationQueue alloc] init] addOperationWithBlock:
     ^{
         [self getData:sourceURL];
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             // Finish up on main thread
             [self downloadFinished];
         }];
     }];
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
    
    // Allow user to pick short or long data
    NSArray *items = [@"Short Long Wrong" componentsSeparatedByString:@" "];
	seg = [[UISegmentedControl alloc] initWithItems:items];
	seg.selectedSegmentIndex = 0;
	seg.segmentedControlStyle = UISegmentedControlStyleBar;
	self.navigationItem.titleView = seg;
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
    [log appendString:@"\n"];
    [log appendString:outstring];

    // Perform GUI update on main thread
    [[NSOperationQueue mainQueue] addOperationWithBlock:^(){
        textView.text = log;
    }];
}

- (void) viewDidAppear:(BOOL)animated
{
    textView.frame = self.view.bounds;
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
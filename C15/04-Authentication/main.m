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

@interface TestBedViewController : UIViewController <NSURLConnectionDelegate>
{
    UIWebView *webView;
    BOOL shouldFail;
    BOOL hasBeenTested;
}
@end

@implementation TestBedViewController
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", htmlString);
    [webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://ericasadun.com"]];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Failed. Error: %@", [error localizedFailureReason]);
    [webView loadHTMLString:@"<h1>Failed</h1>" baseURL:nil];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
    NSLog(@"Being queried about credential storage");
    return NO;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if (hasBeenTested)
    {
        NSLog(@"Second time around for authentication challenge. Fail.");
        [webView loadHTMLString:@"<h1>Fail</h1>" baseURL:nil];
        return;
    }
    else 
        hasBeenTested = shouldFail;
    
    NSString *username = @"PrivateAccess";
    NSString *password = @"tuR7!mZ#eh";

    NSURLCredential *credential = [NSURLCredential credentialWithUser:username password:shouldFail ? nil : password persistence:NSURLCredentialPersistenceNone];
	[[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
}

- (void) go
{
    NSURL *url = [NSURL URLWithString:@"http://ericasadun.com/Private"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    
    hasBeenTested = NO;
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
}

- (void) toggle
{
    shouldFail = !shouldFail;
    self.title = shouldFail ? @"Should fail" : @"Should succeed";
}

#pragma mark -

#pragma mark Setup
- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Go", @selector(go));
    self.navigationItem.leftBarButtonItem = BARBUTTON(@"Toggle", @selector(toggle));
    
    webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:webView];
}

- (void) viewDidAppear:(BOOL)animated
{
    webView.frame = self.view.bounds;
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
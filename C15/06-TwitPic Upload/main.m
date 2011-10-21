/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "TwitPicOperation.h"
#import "XMLParser.h"
#import "TreeNode.h"
#import "UIColor-Random.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define HOST    @"twitpic.com"

@interface PasswordController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UITextField *username;
    IBOutlet UITextField *password;
}
- (IBAction) done:(id)sender;
- (IBAction) cancel:(id)sender;
@end

@implementation PasswordController
- (void) viewWillAppear:(BOOL)animated
{
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:HOST port:0 protocol:@"http" realm:nil 
     authenticationMethod:nil];
        
    NSURLCredential *credential = [[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:protectionSpace];
    if (credential)
    {
        username.text = credential.user;
        password.text = credential.password;
    }
}

- (void) storeCredentials
{
    NSURLCredential *credential = [NSURLCredential credentialWithUser:username.text password:password.text persistence: NSURLCredentialPersistencePermanent];
    NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:HOST port:0 protocol:@"http" realm:nil authenticationMethod:nil];
    
    // Most recent is always default credential
    [[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential:credential forProtectionSpace:protectionSpace];
}

- (IBAction) done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    [self storeCredentials];
}

- (IBAction) cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

// User tapping "done" means done
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self done:nil];
    return YES;
}

// Only enable cancel on edits
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // Empty password when the user name changes
    if (textField == username)
        password.text = @"";
    
    self.navigationItem.leftBarButtonItem.enabled = YES;
}

// Watch for known usernames during text edits
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField != username) return YES;
    
    // Calculate the target string that will occupy the field
    NSString *targetString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (!targetString) return YES;
    if (!targetString.length) return YES;
    
    // Always check if there's a matching password on file
    NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:HOST port:0 protocol:@"http" realm:nil authenticationMethod:nil];
    NSDictionary *credentialDictionary = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:protectionSpace];
    NSURLCredential *pwCredential = [credentialDictionary objectForKey:targetString];
    if (!pwCredential) return YES;
    
    // Match!
    password.text = pwCredential.password;
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
#pragma mark -

#pragma mark Tests
- (void) action: (id) sender
{
    UINavigationController *nav = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    if (IS_IPAD)
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentModalViewController:nav animated:YES];
}

- (void) doneTweeting: (NSString *) message
{
    UITextView *textView = (UITextView *) self.view;
    
    if ([message hasPrefix:@"ERROR"])
    {
        NSLog(@"%@", message);
        textView.text = message;
        return;
    }

    // Retrieve message data
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    TreeNode *node = [[XMLParser sharedInstance] parseXMLFromData:data];
    NSString *urlPath = [node leafForKey:@"mediaurl"];
    if (!urlPath)
    {
        textView.text = [@"Did not receive valid URL from TwitPic.\n" stringByAppendingString:[node dump]];
        return;
    }

    textView.text = urlPath;
}

- (void) createWithColor: (UIColor *) aColor
{
    CGRect rect = (CGRect){.size = CGSizeMake(320.0f, 320.0f)};
    UIGraphicsBeginImageContext(rect.size);
    [[UIColor whiteColor] set];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
    [aColor set];
    [[UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 40.0f, 40.0f) cornerRadius:32.0f] fill];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/out.jpg"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [UIImageJPEGRepresentation(image, 0.75f) writeToURL:url atomically:YES];
}

- (void) send: (id) sender
{
    [self createWithColor:[UIColor randomColor]];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/out.jpg"];
    TwitPicOperation *op = [TwitPicOperation operationWithDelegate:self andPath:path];
    [op start];    
}

#pragma mark -

#pragma mark Setup
- (void) loadView
{
    [super loadView];
    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.frame];
    textView.font = [UIFont fontWithName:@"Futura" size: IS_IPAD ? 24.0f : 14.0f];
    textView.editable = NO;
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;    
    self.view = textView;

    self.navigationItem.leftBarButtonItem = BARBUTTON(@"Settings", @selector(action:));
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Send", @selector(send:));
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
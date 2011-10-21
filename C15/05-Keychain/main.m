/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define HOST    @"ericasadun.com"

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
    
    NSDictionary *credentialDictionary = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:protectionSpace];
    NSLog(@"%@", credentialDictionary);
    
    NSURLCredential *credential = [[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:protectionSpace];
    if (credential)
    {
        username.text = credential.user;
        password.text = credential.password;
    }
    
    // Never log credentials in real world deployment
    NSLog(@"Loading [%@, %@]", username.text, password.text);
}

- (void) storeCredentials
{
    NSURLCredential *credential = [NSURLCredential credentialWithUser:username.text password:password.text persistence: NSURLCredentialPersistencePermanent];
    NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:HOST port:0 protocol:@"http" realm:nil authenticationMethod:nil];
    
    // Most recent is always default credential
    [[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential:credential forProtectionSpace:protectionSpace];
    
    NSLog(@"%@", [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:protectionSpace]);
}

- (IBAction) done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    [self storeCredentials];

    // Never log credentials in real world deployment
    NSLog(@"Storing [%@, %@]", username.text, password.text);
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

#pragma mark -

#pragma mark Setup
- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
}

- (void) viewDidAppear:(BOOL)animated
{
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
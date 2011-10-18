/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define SYSBARBUTTON(ITEM, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR]

#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface KeyInputToolbar: UIToolbar <UIKeyInput>
{
	NSMutableString *string;
}
@end

@implementation KeyInputToolbar

// Is there text available that can be deleted
- (BOOL) hasText
{
	if (!string || !string.length) return NO;
	return YES;
}

- (void) resume
{
    [self becomeFirstResponder];
}

// Reload the toolbar with the string
- (void) update
{
	NSMutableArray *theItems = [NSMutableArray array];
	[theItems addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	[theItems addObject:BARBUTTON(string, @selector(resume))];
	[theItems addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	
	self.items = theItems;	
}

// Insert new text into the string
- (void)insertText:(NSString *)text
{
	if (!string) string = [NSMutableString string];
	[string appendString:text];
	[self update];
}

// Delete one character
- (void)deleteBackward
{
	// Super caution, even if hasText reports YES
	if (!string) 
	{
		string = [NSMutableString string];
		return;
	}
	
	if (!string.length) 
		return;
	
	// Remove a character
	[string deleteCharactersInRange:NSMakeRange(string.length - 1, 1)];
	[self update];
}

- (BOOL)canBecomeFirstResponder 
{ 
	return YES; 
}

// Do not use this in App Store code, kids. Allows you to force Hardware keyboard only interaction
/* - (void) disableOnscreenKeyboard
 {
 void *gs = dlopen("/System/Library/PrivateFrameworks/GraphicsServices.framework/GraphicsServices", RTLD_LAZY);
 int (*kb)(BOOL yorn) = (int (*)(BOOL))dlsym(gs, "GSEventSetHardwareKeyboardAttached");
 kb(YES);
 dlclose(gs);	
 } */


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
	// [self disableOnscreenKeyboard]; // App Store unsafe
	[self becomeFirstResponder];
}	
@end

@interface TestBedViewController : UIViewController
{
    KeyInputToolbar *kit;
}
@end

@implementation TestBedViewController

- (void) done: (id) sender
{
    [kit resignFirstResponder];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];    
    self.view.frame = [[UIScreen mainScreen] applicationFrame];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Done", @selector(done:));
    
	kit = [[KeyInputToolbar alloc] initWithFrame:CGRectMake(0.0f, 60.0f, self.view.frame.size.width, 44.0f)];
	kit.userInteractionEnabled = YES;
	kit.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:kit];
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
    [application setStatusBarHidden:YES];
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    [[UIToolbar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
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
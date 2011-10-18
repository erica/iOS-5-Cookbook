/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define SYSBARBUTTON(ITEM, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR] 
#define SYSBARBUTTON_TARGET(ITEM, TARGET, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:TARGET action:SELECTOR]

#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define DATAPATH [NSHomeDirectory() stringByAppendingFormat:@"/Library/data.txt"]

@interface TestBedViewController : UIViewController <UITextViewDelegate>
{
	UITextView *tv;
	UIToolbar *tb;
}
@end

@implementation TestBedViewController 
CGRect CGRectShrinkHeight(CGRect rect, CGFloat amount)
{
	return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height - amount);
}

- (void) archiveData
{
	[tv.text writeToFile:DATAPATH atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

// Decide whether to load the accessory view with or without the Done key
- (void) loadAccessoryView
{
	NSMutableArray *items = [NSMutableArray array];
	UIBarButtonItem *spacer = SYSBARBUTTON(UIBarButtonSystemItemFixedSpace, nil);
	spacer.width = 40.0f;
    
	BOOL canUndo = [tv.undoManager canUndo];
    UIBarButtonItem *undoItem = SYSBARBUTTON_TARGET(UIBarButtonSystemItemUndo, tv.undoManager, @selector(undo));
    undoItem.enabled = canUndo;
    [items addObject:undoItem];
	[items addObject:spacer];
    
	BOOL canRedo = [tv.undoManager canRedo];
    UIBarButtonItem *redoItem = SYSBARBUTTON_TARGET(UIBarButtonSystemItemRedo, tv.undoManager, @selector(redo));
    redoItem.enabled = canRedo;
    [items addObject:redoItem];
	[items addObject:spacer];
    
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	[items addObject:BARBUTTON(@"Done", @selector(leaveKeyboardMode))];
    
	tb.items = items;	
}

// Returns a plain accessory view
- (UIToolbar *) accessoryView
{
	tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
    tb.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	tb.tintColor = [UIColor darkGrayColor];
	return tb;
}

// Respond to the two accessory buttons
- (void) leaveKeyboardMode { [tv resignFirstResponder];	[self archiveData];}
- (void) clearText { [tv setText:@""]; }

- (BOOL) isUsingHardwareKeyboard: (CGRect) kbounds
{
    // Decide whether to show the Done button
	CGFloat startPoint = tb.superview.frame.origin.y;
	CGFloat endHeight = startPoint + kbounds.size.height;
	CGFloat viewHeight = self.view.window.frame.size.height;
	BOOL usingHardwareKeyboard = endHeight > viewHeight;
    return usingHardwareKeyboard;
}

- (void) keyboardDidHide: (NSNotification *) notification
{
	// return to previous text view size
	tv.frame = self.view.bounds;
}

- (void) keyboardDidShow: (NSNotification *) notification
{
    
	// Retrieve the keyboard bounds via the notification userInfo dictionary
	CGRect kbounds;
	NSDictionary *userInfo = [notification userInfo];
	[(NSValue *)[userInfo objectForKey:@"UIKeyboardBoundsUserInfoKey"] getValue:&kbounds];
    [self loadAccessoryView];
}

- (void) updateTextViewBounds: (NSNotification *) notification
{
	if (![tv isFirstResponder])	 // no keyboard
	{
		tv.frame = self.view.bounds;
		return;
	}
	
	CGRect newframe = self.view.bounds;
	newframe.size.height -= (self.view.frame.size.height - (tb.superview.frame.origin.y - 44.0f));
	tv.frame = newframe;	
}

- (void)textViewDidChange:(UITextView *)textView
{
	[self loadAccessoryView];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];    
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    
    tv = [[UITextView alloc] initWithFrame:self.view.bounds];
	tv.font = [UIFont fontWithName:@"Georgia" size:(IS_IPAD) ? 24.0f : 14.0f];
    tv.inputAccessoryView = [self accessoryView];
    tv.delegate = self;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:DATAPATH])
    {
        NSString *string = [NSString stringWithContentsOfFile:DATAPATH encoding:NSUTF8StringEncoding error:nil];
		tv.text = string;
    }

	[self.view addSubview:tv];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTextViewBounds:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self updateTextViewBounds:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
    TestBedViewController *tbvc;
}
@end
@implementation TestBedAppDelegate

- (void) applicationWillResignActive:(UIApplication *)application
{
    [tbvc archiveData];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    [application setStatusBarHidden:YES];
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	tbvc = [[TestBedViewController alloc] init];
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
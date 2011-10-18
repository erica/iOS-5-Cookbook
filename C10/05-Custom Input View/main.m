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

@interface UIView (FirstResponderUtility)
+ (UIView *) currentResponder;
@end

@implementation UIView (FirstResponderUtility)
- (UIView *) findFirstResponder
{
	if ([self isFirstResponder]) return self;
	
	for (UIView *view in self.subviews)
	{
		UIView *responder = [view findFirstResponder];
        if (!responder) continue;
        return responder;
	}
	
	return nil;
}

+ (UIView *) currentResponder
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
	return [keyWindow findFirstResponder];
}
@end

@interface InputToolbar : UIToolbar
{
	UIView *responderView;
}
@end

@implementation InputToolbar
- (void) appendString: (NSString *) string
{
	if (!responderView || ![responderView isFirstResponder]) 
	{
		responderView = [UIView currentResponder];
		if (!responderView) return;
	}
	
	if ([responderView isKindOfClass:[UITextView class]])
    {
        UITextView *textView = (UITextView *) responderView;
		textView.text = [textView.text stringByAppendingString:string];
    }
	else 
		NSLog(@"Cannot append %@ to unknown class type (%@)", 
              string, [responderView class]);
}

// Perform the two appends
- (void) hello: (id) sender {[self appendString:@"Hello "];}
- (void) world: (id) sender {[self appendString:@"World "];}

- (id) initWithFrame: (CGRect) aFrame
{
	if (!(self = [super initWithFrame: aFrame])) return self;
	
	NSMutableArray *theItems = [NSMutableArray array];
	[theItems addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	[theItems addObject:BARBUTTON(@"Hello", @selector(hello:))];
	[theItems addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	[theItems addObject:BARBUTTON(@"World", @selector(world:))];
	[theItems addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	self.items = theItems;
	
	return self;
}
@end

@interface TestBedViewController : UIViewController
{
    UITextView *textView;
}
@end

@implementation TestBedViewController

- (void) done: (id) sender
{
    [[UIView currentResponder] resignFirstResponder];
}

- (void) viewDidAppear:(BOOL)animated
{
    textView.frame = self.view.frame;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Done", @selector(done:));

    textView = [[UITextView alloc] init];
    textView.font = [UIFont fontWithName:@"Georgia" size:IS_IPAD ? 36.0f : 18.0f];
    [self.view addSubview:textView];
    
    InputToolbar *itb = [[InputToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 44.0f)];
	textView.inputView = itb;
    
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
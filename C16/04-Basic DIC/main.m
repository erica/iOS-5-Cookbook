/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UIColor-Random.h"
#import "UTIHelper.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface TestBedViewController : UIViewController <UIDocumentInteractionControllerDelegate>
{
    NSString *path;
    UIDocumentInteractionController *dic;
}
@end

@implementation TestBedViewController

#pragma mark Dismiss
// This implementation holds onto the dic. Release it on dismiss
- (void) documentInteractionControllerDidDismissOpenInMenu: (UIDocumentInteractionController *) controller { dic = nil; }
- (void) documentInteractionControllerDidDismissOptionsMenu: (UIDocumentInteractionController *) controller { dic = nil; }

#pragma mark Test for Open-ability
-(BOOL)canOpen: (NSURL *) fileURL 
{
    UIDocumentInteractionController *tmp = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    tmp.delegate = self;
    BOOL success = [tmp presentOpenInMenuFromRect:CGRectZero inView:self.view animated:NO];
    [tmp dismissMenuAnimated:NO];
    return success;
}

#pragma mark QuickLook
- (UIViewController *) documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}

- (UIView *) documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
    return self.view;
}

- (CGRect) documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller
{
    return self.view.frame;
}

#pragma mark Options Menu
- (BOOL) documentInteractionController:(UIDocumentInteractionController *)controller performAction:(SEL)action
{
    NSLog(@"Performing Action %@", NSStringFromSelector(action));

    if (action == @selector(copy:))
    {
        // Copies document URL, not document data
        // [UIPasteboard generalPasteboard].URL = dic.URL;
        
        // For this example, just copy the image
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        [UIPasteboard generalPasteboard].image = image;
        return YES;
    }
    
    if (action == @selector(print:))
    {
        if ([UIPrintInteractionController canPrintURL:controller.URL])
        {
            NSLog(@"Item is printable.");
            [UIPrintInteractionController sharedPrintController].printingItem = controller.URL;
            if (IS_IPAD)
            {
                [[UIPrintInteractionController sharedPrintController] presentFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES completionHandler:^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError *error)
                 {
                     
                 }];
            }
            else
            {
                [[UIPrintInteractionController sharedPrintController] presentAnimated:YES completionHandler:^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError *error)
                 {
                     
                 }];
            }
        }
    }
    
    return YES;
}

- (BOOL) documentInteractionController:(UIDocumentInteractionController *)controller canPerformAction:(SEL)action
{
    NSLog(@"Action Test Request %@", NSStringFromSelector(action));
    
    if (action == @selector(copy:))
    {
        // Copy only items under 5MB
        long long fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil].fileSize;
        return (fileSize < 5 * 1024 * 1024);
    }
    
    if (action == @selector(print:))
    {
        return [UIPrintInteractionController isPrintingAvailable];
    }
    
    return YES;
}

- (void) options: (UIBarButtonItem *) bbi
{
    if (dic)
        [dic dismissMenuAnimated:NO];
    
    dic = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
    dic.delegate = self;
    [dic presentOptionsMenuFromBarButtonItem:bbi animated:YES];
}

- (void) open: (UIBarButtonItem *) bbi
{
    if (dic)
        [dic dismissMenuAnimated:NO];
    
    dic = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
    dic.delegate = self;
    [dic presentOpenInMenuFromBarButtonItem:bbi animated:YES];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Open", @selector(open:));
    self.navigationItem.leftBarButtonItem = BARBUTTON(@"Options", @selector(options:));
    
    // Create a new image
    path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Image.jpg"];
    NSData *data = [UIColor randomSwatchData];
    [data writeToFile:path atomically:YES];
}

- (void) viewDidAppear:(BOOL)animated
{
    // aView.frame = self.view.bounds;
    if (![self canOpen:[NSURL fileURLWithPath:path]])
        self.navigationItem.rightBarButtonItem = nil;
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
    [application setStatusBarHidden:YES];
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
/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UIColor-Random.h"
#import "DocWatchHelper.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define kImageReady @"ImageFileIsReadyToReadNotification"

@interface TestBedViewController : UIViewController
{
    UIImageView *imageView;
    DocWatchHelper *helper;
}
@end

@implementation TestBedViewController

#pragma mark -
- (void) updateDocuments: (NSNotification *) notification
{
    NSError *error;
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSArray *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:&error];
    if (!fileArray)
    {
        NSLog(@"Error reading Documents folder: %@", error.localizedFailureReason);
        return;
    }
    
    NSString *fileArrayString = [fileArray componentsJoinedByString:@", "];
    NSLog(@"Files in Documents folder have changed: %@", fileArrayString);
}

- (void) setImage: (NSNotification *) notification
{
    NSString *path = notification.object;
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    imageView.image = image;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:imageView];
    
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    helper = [DocWatchHelper watcherForPath:documentsPath];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDocuments:) name:kDocumentChanged object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setImage:) name:kImageReady object:nil];
}

- (void) viewDidAppear:(BOOL)animated
{
    imageView.frame = self.view.bounds;
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

- (NSString *) findAlternativeNameForPath: (NSString *) path
{
    NSString *ext = path.pathExtension;
    NSString *base = [path stringByDeletingPathExtension];
    
    for (int i = 0; i < 999; i++) // we have limits here
    {
        NSString *dest = [NSString stringWithFormat:@"%@-%d.%@", base, i, ext];
        if (![[NSFileManager defaultManager] fileExistsAtPath:dest])
            return dest;
    }
    
    NSLog(@"Exhausted possible names for file %@. Bailing.", path.lastPathComponent);
    return nil;
}

- (void) performDelayedNotificationWithPath: (NSString *) path
{
    NSNotification *notification = [NSNotification notificationWithName:kImageReady object:path];
    [[NSNotificationCenter defaultCenter] performSelector:@selector(postNotification:) withObject:notification afterDelay:4.0f];
}

- (void) cleanInboxIfNeeded
{
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *inboxPath = [documentsPath stringByAppendingPathComponent:@"Inbox"];
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:inboxPath isDirectory:&isDir])
        return;
    
    NSError *error;
    BOOL success;
    
    if (!isDir)
    {
        success = [[NSFileManager defaultManager] removeItemAtPath:inboxPath error:&error];
        if (!success)
        {
            NSLog(@"Error deleting Inbox file (not directory): %@", error.localizedFailureReason);
            return;
        }
    }
    
    NSArray *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:inboxPath error:&error];
    if (!fileArray)
    {
        NSLog(@"Error reading contents of Inbox: %@", error.localizedFailureReason);
        return;
    }
    
    NSUInteger initialCount = fileArray.count;
    
    for (NSString *filename in fileArray)
    {
        NSString *source = [inboxPath stringByAppendingPathComponent:filename];
        NSString *dest = [documentsPath stringByAppendingPathComponent:filename];
        
        // Is the file already there?
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:dest];
        if (exists) 
            dest = [self findAlternativeNameForPath:dest];
        
        if (!dest)
        {
            NSLog(@"Error. File name conflict could not be resolved for %@. Bailing", filename);
            continue;
        }
        
        success = [[NSFileManager defaultManager] moveItemAtPath:source toPath:dest error:&error];
        if (!success)
        {
            NSLog(@"Error moving file %@ to Documents from Inbox: %@", filename, error.localizedFailureReason);
            continue;
        }
        
        [self performDelayedNotificationWithPath:dest];
    }
    
    // Inbox should now be empty
    fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:inboxPath error:&error];
    if (!fileArray)
    {
        NSLog(@"Error reading contents of Inbox: %@", error.localizedFailureReason);
        return;
    }
    
    if (fileArray.count)
    {
        NSLog(@"Error clearing out inbox. %d items still remain", fileArray.count);
        return;
    }
    
    // Remove the inbox
    success = [[NSFileManager defaultManager] removeItemAtPath:inboxPath error:&error];
    if (!success)
    {
        NSLog(@"Error removing inbox: %@", error.localizedFailureReason);
        return;
    }
    
    NSLog(@"Moved %d items from the Inbox to the Documents folder", initialCount);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self cleanInboxIfNeeded];
}

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
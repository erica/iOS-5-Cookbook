/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "CloudHelper.h"
#import "UIColor-Random.h"
#import "ImageDocument.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define SharedFileName          @"RandomSwatch.jpg"

@interface TestBedViewController : UIViewController
{
    UIImageView *imageView;
    ImageDocument *imageDocument;
    NSFileCoordinator *coordinator;
}
@end

@implementation TestBedViewController

#pragma mark - 
// User has "created" new content by hitting the refresh button. Store out.
- (void) userRefresh: (id) sender
{
    NSLog(@"User is updating document image");
    
    UIImage *image = [UIColor randomSwatch:320.0f];
    imageDocument.image = image;
    imageView.image = image;
    [imageDocument saveToURL:imageDocument.fileURL 
            forSaveOperation:UIDocumentSaveForOverwriting 
           completionHandler:^(BOOL success){
        NSLog(@"Attempt to save to URL %@", success ? @"succeeded" : @"failed"); 
    }];
}

// Informal image document delegate callback
- (void) imageUpdated: (id) sender
{
    NSLog(@"Document reports updated image");
    imageView.image = imageDocument.image;
}

// Establish document at the start of the application run
- (void) establishDocument
{
    // Establish helper
    [CloudHelper setupUbiquityDocumentsFolder];
    
    // Determine whether the file exists yet or not
    NSURL *theURL = [CloudHelper fileURL:SharedFileName];
    if (!theURL)
    {
        NSLog(@"File not found. Creating it.");
        NSURL *localURL = [CloudHelper localFileURL:SharedFileName];
        NSData *data = [UIColor randomSwatchData:320.0f];
        [data writeToURL:localURL atomically:YES];
        [CloudHelper setUbiquitous:YES for:SharedFileName];
    }
    
    // Failsafe check that the file really is there
    theURL = [CloudHelper fileURL:SharedFileName];
    if (!theURL)
    {
        NSLog(@"Error creating file. Bailing");
        return;
    }
    
    // Establishing image document for cloud URL
    imageDocument = [[ImageDocument alloc] initWithFileURL:theURL];
    imageDocument.delegate = self;
    [imageDocument openWithCompletionHandler:^(BOOL success) {
        NSLog(@"Open file was: %@", success ? @"successful" : @"failure");
        if (success) imageView.image = imageDocument.image;}];
    
    // Register the document as a presenter
    coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:imageDocument];
    [NSFileCoordinator addFilePresenter:imageDocument];
    
    // Subscribe to and handle state change notifications
    [[NSNotificationCenter defaultCenter] addObserverForName:UIDocumentStateChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification __strong *notification){
        NSLog(@"State Changed. %@", imageDocument.stateDescription);
        
        if (imageDocument.documentState == UIDocumentStateInConflict)
        {
            NSError *error;
            NSLog(@"Resolving conflict. (Newest wins.)");
            if (![NSFileVersion removeOtherVersionsOfItemAtURL:imageDocument.fileURL error:&error])
            {
                NSLog(@"Error removing other cloud document versions: %@", error.localizedFailureReason);
                return;
            }
            imageView.image = imageDocument.image;
        }
    }];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    imageView = [[UIImageView alloc] initWithImage:nil];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    
    [self establishDocument];
    
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Change", @selector(userRefresh:));
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
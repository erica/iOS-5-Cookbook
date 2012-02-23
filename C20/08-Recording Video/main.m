/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPHONE	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

@interface TestBedViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>
{
    UIPopoverController *popoverController;
    UIImagePickerController *imagePickerController;
}
@end

@implementation TestBedViewController
- (BOOL) videoRecordingAvailable
{
    // The source type must be available
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        return NO;
    
    // And the media type must include the movie type
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    
    return  [mediaTypes containsObject:@"public.movie"];
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
	if (!error) 
		self.title = @"Saved!";
	else 
        NSLog(@"Error saving video: %@", error.localizedFailureReason);
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	// recover video URL
	NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
	
	// check if video is compatible with album
	BOOL compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path);
	
	// save
	if (compatible)
		UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
	
	if (IS_IPHONE)
	{
        [self dismissModalViewControllerAnimated:YES];
        imagePickerController = nil;
	}
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker
{
    [self dismissModalViewControllerAnimated:YES];
    imagePickerController = nil;
}

// Popover was dismissed
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)aPopoverController
{
	imagePickerController = nil;
    popoverController = nil;
}

- (void) recordVideo: (id) sender
{
    if (popoverController)
        return;
    
    imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
	imagePickerController.delegate = self;
	imagePickerController.allowsEditing = YES;
	imagePickerController.videoQuality = UIImagePickerControllerQualityTypeMedium;
	imagePickerController.videoMaximumDuration = 30.0f; // 30 seconds
	imagePickerController.mediaTypes = [NSArray arrayWithObject:@"public.movie"];
	// imagePickerController.mediaTypes = [NSArray arrayWithObjects:@"public.movie", @"public.image", nil];
    
    if (IS_IPHONE)
	{   
        [self presentModalViewController:imagePickerController animated:YES];	
	}
	else 
	{
        if (popoverController) [popoverController dismissPopoverAnimated:NO];
        popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
        popoverController.delegate = self;
        [popoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    if ([self videoRecordingAvailable])
		self.navigationItem.rightBarButtonItem = BARBUTTON(@"Record", @selector(recordVideo:));
	else 
		self.title = @"No Video Recording";
}

- (void) viewDidAppear:(BOOL)animated
{
    // someView.frame = self.view.bounds;
    // someView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
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
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

@interface TestBedViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIVideoEditorControllerDelegate, UIPopoverControllerDelegate>
{
    UIPopoverController *popoverController;
    UIImagePickerController *imagePickerController;
    UIVideoEditorController *videoEditorController;
    NSString *vpath;
}
@end

@implementation TestBedViewController
- (void)videoEditorControllerDidCancel:(UIVideoEditorController *)editor
{
	if (IS_IPHONE)
        [self dismissModalViewControllerAnimated:YES];

    if (popoverController)
    {
        [popoverController dismissPopoverAnimated:NO];
        popoverController = nil;
    }
    
    videoEditorController = nil;
    NSLog(@"Cancelled");
}

- (void)videoEditorController:(UIVideoEditorController *)editor didFailWithError:(NSError *)error
{
	if (IS_IPHONE)
        [self dismissModalViewControllerAnimated:YES];
    
    if (popoverController)
    {
        [popoverController dismissPopoverAnimated:NO];
        popoverController = nil;
    }

    videoEditorController = nil;
	NSLog(@"Video editor failed: %@", error.localizedFailureReason);
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
	if (!error) 
		self.title = @"Saved!";
	else 
        NSLog(@"Error saving video: %@", error.localizedFailureReason);
}

- (void)videoEditorController:(UIVideoEditorController *)editor didSaveEditedVideoToPath:(NSString *)editedVideoPath
{
    videoEditorController = nil;
    vpath = nil;
    
	if (IS_IPHONE)
        [self dismissModalViewControllerAnimated:YES];
    
    if (popoverController)
    {
        [popoverController dismissPopoverAnimated:NO];
        popoverController = nil;
    }

	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Pick", @selector(pickVideo:));
    
    // check if video is compatible with album
	BOOL compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(editedVideoPath);
	
	// save
	if (compatible)
		UISaveVideoAtPathToSavedPhotosAlbum(editedVideoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
}

- (void) doEdit
{
	if (![UIVideoEditorController canEditVideoAtPath:vpath])
	{
		self.title = @"Cannot Edit Video";
		return;
	}
	
	// Can edit 
	videoEditorController = [[UIVideoEditorController alloc] init];
	videoEditorController.videoPath = vpath;
	videoEditorController.delegate = self;
    
    if (IS_IPHONE)
	{   
        [self presentModalViewController:videoEditorController animated:YES];	
	}
	else 
	{
        if (popoverController) [popoverController dismissPopoverAnimated:NO];
        popoverController = [[UIPopoverController alloc] initWithContentViewController:videoEditorController];
        popoverController.delegate = self;
        [popoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	// recover video URL
	NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
	
	if (IS_IPHONE)
	{
        [self dismissModalViewControllerAnimated:YES];
        imagePickerController = nil;
	}
    
    NSLog(@"Path set to %@", url.path);
    vpath = url.path;
    if (popoverController)
    {
        [popoverController dismissPopoverAnimated:NO];
        popoverController = nil;
    }
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Edit", @selector(doEdit));
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
    videoEditorController = nil;
    popoverController = nil;
}

- (void) pickVideo: (id) sender
{
    imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
	imagePickerController.delegate = self;
	imagePickerController.allowsEditing = NO;
	imagePickerController.mediaTypes = [NSArray arrayWithObject:@"public.movie"];
    
    if (IS_IPHONE)
	{   
        [self presentModalViewController:imagePickerController animated:YES];	
	}
	else 
	{
        if (popoverController) [popoverController dismissPopoverAnimated:YES];
        popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
        popoverController.delegate = self;
        [popoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Pick", @selector(pickVideo:));
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
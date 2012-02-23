/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define SYSBARBUTTON(ITEM, TARGET, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:TARGET action:SELECTOR]

#define IS_IPHONE	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define PLAYER [MPMusicPlayerController iPodMusicPlayer]

@interface TestBedViewController : UIViewController <MPMediaPickerControllerDelegate, UIPopoverControllerDelegate>
{
    UIPopoverController *popoverController;
    
    UIToolbar *toolbar;
	UIImageView *imageView;
	MPMediaItemCollection *songs;
}
@end

@implementation TestBedViewController
# pragma mark TOOLBAR CONTENTS
- (NSArray *) playItems
{
	NSMutableArray *items = [NSMutableArray array];
	
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemRewind, self, @selector(rewind))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemPlay, self, @selector(play))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFastForward, self, @selector(fastforward))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
	
	return items;
}

- (NSArray *) pauseItems
{
	NSMutableArray *items = [NSMutableArray array];
	
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemRewind, self, @selector(rewind))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemPause, self, @selector(pause))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFastForward, self, @selector(fastforward))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
	
	return items;
}

#pragma mark PLAYBACK
- (void) pause
{
	[PLAYER pause];
	toolbar.items = [self playItems];
}

- (void) play
{
	[PLAYER play];
	toolbar.items = [self pauseItems];
}

- (void) fastforward
{
	[PLAYER skipToNextItem];
}

- (void) rewind
{
	[PLAYER skipToPreviousItem];
}

#pragma mark STATE CHANGES
- (void) playbackItemChanged: (NSNotification *) notification
{
	// update title and artwork
	self.title = [PLAYER.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
	MPMediaItemArtwork *artwork = [PLAYER.nowPlayingItem valueForProperty: MPMediaItemPropertyArtwork];
	imageView.image = [artwork imageWithSize:[imageView frame].size];
}

- (void) playbackStateChanged: (NSNotification *) notification
{
	// On stop, clear title, toolbar, artwork
	if (PLAYER.playbackState == MPMusicPlaybackStateStopped)
	{
		self.title = nil;
		toolbar.items = nil;
		imageView.image = nil;
	}
}

#pragma mark MEDIA PICKING
- (void)mediaPicker: (MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
	songs = mediaItemCollection;
	[PLAYER setQueueWithItemCollection:songs];
	[toolbar setItems:[self playItems]];
	
	if (IS_IPHONE)
        [self dismissModalViewControllerAnimated:YES];
    else
    {
        [popoverController dismissPopoverAnimated:YES];
        popoverController = nil;
    }
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
	if (IS_IPHONE)
        [self dismissModalViewControllerAnimated:YES];
}

// Popover was dismissed
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)aPopoverController
{
    popoverController = nil;
}


- (void) pick: (UIBarButtonItem *) bbi
{
	MPMediaPickerController *mpc = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
	mpc.delegate = self;
	mpc.prompt = @"Please select items to play";
	mpc.allowsPickingMultipleItems = YES;
    
    if (IS_IPHONE)
	{   
        [self presentModalViewController:mpc animated:YES];	
	}
	else 
	{
        if (popoverController) [popoverController dismissPopoverAnimated:NO];
        popoverController = [[UIPopoverController alloc] initWithContentViewController:mpc];
        popoverController.delegate = self;
        [popoverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
}

#pragma mark INIT VIEW
- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
    
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Pick", @selector(pick:));
    
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    [self.view addSubview:toolbar];
	toolbar.tintColor = COOKBOOK_PURPLE_COLOR;

    float destSize = IS_IPHONE ? 200.0f : 500.0f;
    imageView = [[UIImageView alloc] initWithFrame:(CGRect){.size = CGSizeMake(destSize, destSize)}];
    [self.view addSubview:imageView];
    
    // Stop any ongoing music
	[PLAYER stop];
	
	// Add listeners
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:PLAYER];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackItemChanged:) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:PLAYER];
	[PLAYER beginGeneratingPlaybackNotifications];
}

- (void) viewDidAppear:(BOOL)animated
{
    [UIView animateWithDuration:0.3f animations:^()
     {
         CGFloat height = self.view.bounds.size.height;
         toolbar.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 44.0f);
         toolbar.center = CGPointMake(CGRectGetMidX(self.view.bounds), height - 22.0f);
         
         imageView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - 22.0f);
     }];
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
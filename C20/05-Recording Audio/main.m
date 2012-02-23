/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ModalAlertDelegate.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define SYSBARBUTTON(ITEM, TARGET, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:TARGET action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define FILEPATH [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[self dateString]]
#define XMAX	20.0f


@interface TestBedViewController : UIViewController <AVAudioPlayerDelegate, AVAudioRecorderDelegate>
{
    IBOutlet UIView *controlView;
    
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
	NSTimer *timer;
    
    // Outlets
	IBOutlet UIProgressView *meter1;
	IBOutlet UIProgressView *meter2;
}
@end

@implementation TestBedViewController

- (NSString *) dateString
{
	// return a formatted string for a file name
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"ddMMMYY_hhmmssa";
	return [[formatter stringFromDate:[NSDate date]] stringByAppendingString:@".aif"];
}

- (NSString *) formatTime: (int) num
{
	// return a formatted ellapsed time string
	int secs = num % 60;
	int min = num / 60;
	if (num < 60) return [NSString stringWithFormat:@"0:%02d", num];
	return	[NSString stringWithFormat:@"%d:%02d", min, secs];
}

- (void) updateMeters
{
	// Show the current power levels
	[recorder updateMeters];
	float avg = [recorder averagePowerForChannel:0];
	float peak = [recorder peakPowerForChannel:0];
	meter1.progress = (XMAX + avg) / XMAX;
	meter2.progress = (XMAX + peak) / XMAX;
    
	// Update the current recording time
	self.title = [NSString stringWithFormat:@"%@", [self formatTime:recorder.currentTime]];
}

- (void) say: (NSString *) aString
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:aString message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    ModalAlertDelegate *delegate = [ModalAlertDelegate delegateWithAlert:alertView];
    [delegate show];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	// Prepare UI for recording
	self.title = nil;
	meter1.hidden = NO;
	meter2.hidden = NO;
	{
		// Return to play and record session
		NSError *error;
		if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error])
		{
			NSLog(@"Error: %@", error.localizedFailureReason);
			return;
		}
		self.navigationItem.rightBarButtonItem = BARBUTTON(@"Record", @selector(record));
	}
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)aRecorder successfully:(BOOL)flag
{
	// Stop monitoring levels, time
	[timer invalidate];
	meter1.progress = 0.0f;
	meter1.hidden = YES;
	meter2.progress = 0.0f;
	meter2.hidden = YES;
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = nil;
    
    if (!flag)
        NSLog(@"Recording was flagged as unsuccessful");

    NSURL *url = recorder.url;
    NSString *result = [NSString stringWithFormat:@"File saved to %@", [url.path lastPathComponent]];
	[self say:result];
    
    NSError *error;
	
	// Start playback
	player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (!player)
    {
        NSLog(@"Error establishing player for %@: %@", recorder.url, error.localizedFailureReason);
        return;
    }
	player.delegate = self;
	
	// Change audio session for playback
	if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error])
	{
		NSLog(@"Error updating audio session: %@", error.localizedFailureReason);
		return;
	}
    
	self.title = @"Playing back recording...";
    [player prepareToPlay];
	[player play];
}

- (void) stopRecording
{
	// This causes the didFinishRecording delegate method to fire
	[recorder stop];
}

- (void) continueRecording
{
	// resume from a paused recording
	[recorder record];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Done", @selector(stopRecording));
	self.navigationItem.leftBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemPause, self, @selector(pauseRecording));
}

- (void) pauseRecording
{
	// pause an ongoing recording
	[recorder pause];
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Continue", @selector(continueRecording));
	self.navigationItem.rightBarButtonItem = nil;
}

- (BOOL) record
{
	NSError *error;
	
	// Recording settings
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings setValue: [NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
	[settings setValue: [NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
	[settings setValue: [NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey]; // mono
	[settings setValue: [NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
	[settings setValue: [NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
	[settings setValue: [NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
	
	// File URL
	NSURL *url = [NSURL fileURLWithPath:FILEPATH];
	
	// Create recorder
	recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
	if (!recorder)
	{
		NSLog(@"Error establishing recorder: %@", error.localizedFailureReason);
		return NO;
	}
	
	// Initialize degate, metering, etc.
	recorder.delegate = self;
	recorder.meteringEnabled = YES;
	meter1.progress = 0.0f;
	meter2.progress = 0.0f;
	self.title = @"0:00";
	
	if (![recorder prepareToRecord])
	{
		NSLog(@"Error: Prepare to record failed");
		[self say:@"Error while preparing recording"];
		return NO;
	}
	
	if (![recorder record])
	{
		NSLog(@"Error: Record failed");
		[self say:@"Error while attempting to record audio"];
		return NO;
	}
	
	// Set a timer to monitor levels, current time
	timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
	
	// Update the navigation bar
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Done", @selector(stopRecording));
	self.navigationItem.leftBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemPause, self, @selector(pauseRecording));
    
	return YES;
}

- (BOOL) startAudioSession
{
	// Prepare the audio session
	NSError *error;
	AVAudioSession *session = [AVAudioSession sharedInstance];
	
	if (![session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error])
	{
		NSLog(@"Error setting session category: %@", error.localizedFailureReason);
		return NO;
	}
	
	if (![session setActive:YES error:&error])
	{
		NSLog(@"Error activating audio session: %@", error.localizedFailureReason);
		return NO;
	}
	
	return session.inputIsAvailable;
}

- (void) viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:controlView];

	if ([self startAudioSession])
		self.navigationItem.rightBarButtonItem = BARBUTTON(@"Record", @selector(record));
	else
		self.title = @"No Audio Input Available";
}

#pragma mark - View Setup

- (void) viewDidAppear:(BOOL)animated
{
   controlView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
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

#pragma mark - Application Setup

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
    TestBedViewController *tbvc;
}
@end
@implementation TestBedAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    // [application setStatusBarHidden:YES];
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
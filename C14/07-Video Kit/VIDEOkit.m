//
//  VIDEOkit.m
//  HelloWorld
//
//  Created by Erica Sadun on 5/12/10.
//  Copyright 2010 Up To No Good, Inc. All rights reserved.
//

#import "VIDEOkit.h"

#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)

#define SCREEN_CONNECTED	([UIScreen screens].count > 1)

@implementation VIDEOkit
@synthesize delegate;
@synthesize outwindow, displayLink;

static VIDEOkit *sharedInstance = nil;

- (void) setupExternalScreen
{
	// Check for missing screen
	if (!SCREEN_CONNECTED) return;
	
	// Set up external screen
	UIScreen *secondaryScreen = [[UIScreen screens] objectAtIndex:1];
	UIScreenMode *screenMode = [[secondaryScreen availableModes] lastObject];
	CGRect rect = (CGRect){.size = screenMode.size};
	NSLog(@"Extscreen size: %@", NSStringFromCGSize(rect.size));
	
	// Create new outwindow
	self.outwindow = [[UIWindow alloc] initWithFrame:CGRectZero];
	outwindow.screen = secondaryScreen;
	outwindow.screen.currentMode = screenMode; // Thanks Scott Lawrence
	[outwindow makeKeyAndVisible];
	outwindow.frame = rect;

	// Add base video view to outwindow
	baseView = [[UIImageView alloc] initWithFrame:rect];
	baseView.backgroundColor = [UIColor darkGrayColor];
	[outwindow addSubview:baseView];

	// Restore primacy of main window
	[delegate.view.window makeKeyAndVisible];
}

- (void) updateScreen
{
	// Abort if the screen has been disconnected
	if (!SCREEN_CONNECTED && outwindow)
		self.outwindow = nil;
	
	// (Re)initialize if there's no output window
	if (SCREEN_CONNECTED && !outwindow)
		[self setupExternalScreen];
	
	// Abort if we have encountered some weird error
	if (!self.outwindow) return;
	
	// Go ahead and update
    SAFE_PERFORM_WITH_ARG(delegate, @selector(updateExternalView:), baseView);
}

- (void) screenDidConnect: (NSNotification *) notification
{
    NSLog(@"Screen connected");
    UIScreen *screen = [[UIScreen screens] lastObject];
    
    if (displayLink)
    {
        [displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [displayLink invalidate];
        self.displayLink = nil;
    }
    
    // Check for current display link
    if (!displayLink)
    {
        self.displayLink = [screen displayLinkWithTarget:self selector:@selector(updateScreen)];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void) screenDidDisconnect: (NSNotification *) notification
{
	NSLog(@"Screen disconnected.");
    if (displayLink)
    {
        [displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [displayLink invalidate];
        self.displayLink = nil;
    }
}

- (id) init
{
	if (!(self = [super init])) return self;
	
	// Handle output window creation
	if (SCREEN_CONNECTED) 
        [self screenDidConnect:nil];
	
	// Register for connect/disconnect notifications
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDidConnect:) name:UIScreenDidConnectNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDidDisconnect:) name:UIScreenDidDisconnectNotification object:nil];

	return self;
}

- (void) dealloc
{
    [self screenDidDisconnect:nil];
	self.outwindow = nil;
}

+ (VIDEOkit *) sharedInstance
{
	if (!sharedInstance)	
		sharedInstance = [[self alloc] init];
	return sharedInstance;
}

+ (void) startupWithDelegate: (id) aDelegate
{
    [[self sharedInstance] setDelegate:aDelegate];
}
@end

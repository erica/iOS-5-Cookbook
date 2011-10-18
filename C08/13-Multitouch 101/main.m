/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

@interface TouchTrackerView : UIView
{
	NSMutableDictionary *touchPaths;
}
@end

@implementation TouchTrackerView
- (void) touchesBegan:(NSSet *) touches withEvent:(UIEvent *) event
{
    if (!touchPaths) 
        touchPaths = [NSMutableDictionary dictionary];
    
	for (UITouch *touch in touches)
	{
		NSString *key = [NSString stringWithFormat:@"%d", touch];
		CGPoint pt = [touch locationInView:self];
		
		UIBezierPath *path = [UIBezierPath bezierPath];
		path.lineWidth = 4;
		[path moveToPoint:pt];
		
		[touchPaths setObject:path forKey:key];
	} 
}

- (void) touchesMoved:(NSSet *) touches withEvent:(UIEvent *) event
{
	for (UITouch *touch in touches)
	{
		NSString *key = [NSString stringWithFormat:@"%d", touch];
		UIBezierPath *path = [touchPaths objectForKey:key];
		if (!path) break;
		
		CGPoint pt = [touch locationInView:self];
		[path addLineToPoint:pt];
	}	
	
	[self setNeedsDisplay];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch *touch in touches)
	{
		NSString *key = [NSString stringWithFormat:@"%d", touch];
		[touchPaths removeObjectForKey:key];
	}
    
    [self setNeedsDisplay];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}

- (void) drawRect:(CGRect)rect
{
	[COOKBOOK_PURPLE_COLOR set];
	for (UIBezierPath *path in [touchPaths allValues])
		[path stroke];
	
}

- (id) initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
		self.multipleTouchEnabled = YES;
	
	return self;
}
@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (void) loadView
{
    [super loadView];
    self.view = [[TouchTrackerView alloc] initWithFrame:self.view.frame];
    self.view.backgroundColor = [UIColor whiteColor];
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
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    window.rootViewController = tbvc;
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
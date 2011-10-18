/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

#define POINTSTRING(_CGPOINT_) (NSStringFromCGPoint(_CGPOINT_))
#define VALUE(_INDEX_) [NSValue valueWithCGPoint:points[_INDEX_]]
#define POINT(_INDEX_) [(NSValue *)[points objectAtIndex:_INDEX_] CGPointValue]

@interface UIColor (Random)
@end

@implementation UIColor(Random)
+(UIColor *)randomColor
{
    static BOOL seeded = NO;
    if (!seeded) {
        seeded = YES;
        srandom(time(NULL));
    }
	
	float intensityOffset = 0.25f;
    CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX; red = (red / 2.0f) + intensityOffset;
    CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX; blue = (blue / 2.0f) + intensityOffset;
    CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX; green = (green / 2.0f) + intensityOffset;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}
@end

#pragma mark Geometry Utilities
// Return center of the given rect
CGPoint getRectCenter(CGRect rect)
{
	return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

// Build rect around a given center
CGRect rectAroundCenter(CGPoint center, float dx, float dy)
{
	return CGRectMake(center.x - dx, center.y - dy, dx * 2, dy * 2);
}

// Return dot product of two vectors normalized
float dotproduct (CGPoint v1, CGPoint v2)
{
	float dot = (v1.x * v2.x) + (v1.y * v2.y);
	float a = ABS(sqrt(v1.x * v1.x + v1.y * v1.y));
	float b = ABS(sqrt(v2.x * v2.x + v2.y * v2.y));
	dot /= (a * b);
	
	return dot;
}

// Return distance between two points
float distance (CGPoint p1, CGPoint p2)
{
	float dx = p2.x - p1.x;
	float dy = p2.y - p1.y;
	
	return sqrt(dx*dx + dy*dy);
}

// Return a point with respect to a given origin
CGPoint pointWithOrigin(CGPoint pt, CGPoint origin)
{
	return CGPointMake(pt.x - origin.x, pt.y - origin.y);
}

#pragma mark Circle Detection

// Calculate and return least bounding rectangle
CGRect boundingRect(NSArray *points)
{
	CGRect rect = CGRectZero;
	CGRect ptRect;
	
	for (int i = 0; i < points.count; i++)
	{
        CGPoint pt = POINT(i);
		ptRect = CGRectMake(pt.x, pt.y, 0.0f, 0.0f);
		rect = (CGRectEqualToRect(rect, CGRectZero)) ? ptRect : CGRectUnion(rect, ptRect);
	}
	
	return rect;
}

#define DX(p1, p2)	(p2.x - p1.x)
#define DY(p1, p2)	(p2.y - p1.y)
#define SIGN(NUM) (NUM < 0 ? (-1) : 1)
#define DEBUG NO

CGRect testForCircle(NSArray *points, NSDate *firstTouchDate)
{
	if (points.count < 2) 
	{
		if (DEBUG) NSLog(@"Too few points (2) for circle");
		return CGRectZero;
	}
	
	// Test 1: duration tolerance
	float duration = [[NSDate date] timeIntervalSinceDate:firstTouchDate];
	if (DEBUG) NSLog(@"Transit duration: %0.2f", duration);
        
        float maxDuration = 2.0f;
        if (duration > maxDuration) // allows longer time for use in simulator
        {
            if (DEBUG) NSLog(@"Excessive touch duration: %0.2f seconds vs %0.1f seconds", duration, maxDuration);
            return CGRectZero;
        }
	
	// Test 2: The number of direction changes should be limited to near 4
	int inflections = 0;
	for (int i = 2; i < (points.count - 1); i++)
	{
		float dx = DX(POINT(i), POINT(i-1));
		float dy = DY(POINT(i), POINT(i-1));
		float px = DX(POINT(i-1), POINT(i-2));
		float py = DY(POINT(i-1), POINT(i-2));
		
		if ((SIGN(dx) != SIGN(px)) || (SIGN(dy) != SIGN(py)))
			inflections++;
	}
	
	if (inflections > 5)
	{
		if (DEBUG) NSLog(@"Excessive number of inflections (%d vs 4). Fail.", inflections);
		return CGRectZero;
	}
	
	// Test 3: The start and end points must be between some number of points of each other
	float tolerance = [[[UIApplication sharedApplication] keyWindow] bounds].size.width / 3.0f;	
	if (distance(POINT(0), POINT(points.count - 1)) > tolerance)
	{
		if (DEBUG) NSLog(@"Start and end points too far apart. Fail.");
		return CGRectZero;
	}
	
	// Test 4: Count the distance traveled in degrees. 
	CGRect circle = boundingRect(points);
	CGPoint center = getRectCenter(circle);
	float distance = ABS(acos(dotproduct(pointWithOrigin(POINT(0), center), pointWithOrigin(POINT(1), center))));
	for (int i = 1; i < (points.count - 1); i++)
		distance += ABS(acos(dotproduct(pointWithOrigin(POINT(i), center), pointWithOrigin(POINT(i+1), center))));
        
        float transitTolerance = distance - 2 * M_PI;
        
        if (transitTolerance < 0.0f) // fell short of 2 PI
        {
            if (transitTolerance < - (M_PI / 4.0f)) // 45 degrees or more
            {
                if (DEBUG) NSLog(@"Transit was too short, under 315 degrees");
                return CGRectZero;
            }
        }
	
	if (transitTolerance > M_PI) // additional 180 degrees
	{
		if (DEBUG) NSLog(@"Transit was too long, over 540 degrees");
		return CGRectZero;
	}
	
	return circle;
}

@interface CircleRecognizer : UIGestureRecognizer
{
	NSMutableArray *points;	
	NSDate *firstTouchDate;
}
@end

@implementation CircleRecognizer

// called automatically by the runtime after the gesture state has been set to UIGestureRecognizerStateEnded
// any internal state should be reset to prepare for a new attempt to recognize the gesture
// after this is received all remaining active touches will be ignored (no further updates will be received for touches that had already begun but haven't ended)
- (void)reset
{
	[super reset];
	
	points = nil;
	firstTouchDate = nil;
	self.state = UIGestureRecognizerStatePossible;
}

// mirror of the touch-delivery methods on UIResponder
// UIGestureRecognizers aren't in the responder chain, but observe touches hit-tested to their view and their view's subviews
// UIGestureRecognizers receive touches before the view to which the touch was hit-tested
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	
	if (touches.count > 1) 
	{
		self.state = UIGestureRecognizerStateFailed;
		return;
	}
	
	points = [NSMutableArray array];
	firstTouchDate = [NSDate date];
	UITouch *touch = [touches anyObject];
	[points addObject:[NSValue valueWithCGPoint:[touch locationInView:self.view]]];	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
	UITouch *touch = [touches anyObject];
	[points addObject:[NSValue valueWithCGPoint:[touch locationInView:self.view]]];	
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent: event];
	BOOL detectionSuccess = !CGRectEqualToRect(CGRectZero, testForCircle(points, firstTouchDate));
	if (detectionSuccess)
		self.state = UIGestureRecognizerStateRecognized;
	else
		self.state = UIGestureRecognizerStateFailed;
}
@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController

- (void) handleCircleRecognizer:(UIGestureRecognizer *) recognizer
{
	// Respond to a recognition event by updating the background
	NSLog(@"Circle recognized");
	self.view.backgroundColor = [UIColor randomColor];
}
- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CircleRecognizer *recognizer = [[CircleRecognizer alloc] initWithTarget:self action:@selector(handleCircleRecognizer:)]; 
	[self.view addGestureRecognizer:recognizer];
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
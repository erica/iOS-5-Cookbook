/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "StringHelper.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface CTCircleView : UIView
@property (nonatomic, strong) NSAttributedString *string;
@end

@implementation CTCircleView
@synthesize string;

- (id) initWithAttributedString: (NSAttributedString *) aString
{
	if (!(self = [super initWithFrame:CGRectZero])) return self;
    
	self.backgroundColor = [UIColor clearColor];
	string = aString;
	
	return self;
}

// Draw text into a circle using Core Text and Quartz
- (void) drawRect:(CGRect)rect
{
	[super drawRect: rect];
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Flip the context
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	// Calculate a centered square
	CGFloat minSide = MIN(self.frame.size.width, self.frame.size.height);
	CGRect squareRect = CGRectMake(CGRectGetMidX(self.frame) - minSide / 2.0f, CGRectGetMidY(self.frame) - minSide / 2.0f, minSide, minSide);
	CGRect insetRect = CGRectInset(squareRect, 30.0f, 30.0f);
    
	// Create an ellipse path
	CGMutablePathRef backPath = CGPathCreateMutable();
	CGPathAddEllipseInRect(backPath, NULL, insetRect); // circle path
	
	// Stroke that path
	CGContextAddPath(context, backPath);
	CGContextSetLineWidth(context, 4.0f);
	[[UIColor blackColor] setStroke];
	CGContextStrokePath(context);
    
	// Fill that path
	CGContextAddPath(context, backPath);
	[[COOKBOOK_PURPLE_COLOR colorWithAlphaComponent:0.5f] setFill];
	CGContextFillPath(context);
	
	CFRelease(backPath);
	
	// Inset even further, so the text won't touch the edges
	insetRect = CGRectInset(insetRect, 10.0f, 10.0f);
	CGMutablePathRef insetPath = CGPathCreateMutable();
	CGPathAddEllipseInRect(insetPath, NULL, insetRect);
	
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)string);
	CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, string.length), insetPath, NULL);
	CTFrameDraw(theFrame, context);
	
	CFRelease(framesetter);
	CFRelease(theFrame);
	CFRelease(insetPath);
}
@end

@interface TestBedViewController : UIViewController
{
    CTCircleView *cView;
}
@end

@implementation TestBedViewController
- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *testString = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus ac lectus ac elit fringilla hendrerit. Aliquam erat volutpat. In magna enim, rutrum in malesuada et, aliquet sit amet libero. Sed posuere bibendum pharetra. Nulla facilisi. Aliquam non justo eu nulla egestas mattis consequat at est. Nam id odio id dui convallis mollis. Pellentesque adipiscing quam ut lacus dignissim a luctus orci iaculis. Ut dapibus ultrices faucibus. Suspendisse potenti. Nulla id quam velit. Fusce id purus lectus, sed pulvinar erat. Ut nisi eros, venenatis nec aliquet vel, scelerisque vitae urna. Fusce id nisl nec massa laoreet ultrices. Proin tortor lorem, tristique sed semper nec, dignissim sed lorem. Suspendisse porttitor, arcu quis lacinia aliquet, augue nibh sollicitudin tortor, vel dapibus massa urna vitae mi. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Phasellus eros mi, elementum volutpat tincidunt in, viverra ut orci. Aliquam erat volutpat. Pellentesque porttitor bibendum ante, id malesuada metus faucibus a. Fusce augue nisi, dapibus at auctor sit amet, scelerisque ac velit. Nunc tincidunt tincidunt libero, eget molestie massa fringilla sit amet. Morbi bibendum consectetur mollis. Morbi lectus ipsum, posuere quis pellentesque id, mollis in tellus. Sed turpis elit, tempus quis tempor a, tempor vel erat. Integer facilisis volutpat congue. Fusce at felis in lectus imperdiet eleifend eget non ipsum.";
	
	// The line break mode wraps character-by-character
	uint8_t breakMode = kCTLineBreakByCharWrapping;
	CTParagraphStyleSetting wordBreakSetting = {
		kCTParagraphStyleSpecifierLineBreakMode,
		sizeof(uint8_t),
		&breakMode
	};
	CTParagraphStyleSetting alignSettings[1] = {wordBreakSetting};
	CTParagraphStyleRef paraStyle = CTParagraphStyleCreate(alignSettings, 1);
    
	// Set the text 
	CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"Georgia", 16.0f, NULL);
    
	// Create the attributed string
	NSDictionary *attrDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
									(__bridge id)fontRef, (NSString *)kCTFontAttributeName, 
									(__bridge id)paraStyle, (NSString *)kCTParagraphStyleAttributeName,
									nil];	
	NSAttributedString *attString = [[NSAttributedString alloc] initWithString:testString attributes:attrDictionary];
	CFRelease(fontRef);
	CFRelease(paraStyle);
    
	// Add the attributed string to the CTCircleView
    cView = [[CTCircleView alloc] initWithAttributedString:attString];
	[self.view addSubview:cView];
	cView.frame = self.view.bounds;

}

- (void) viewDidAppear:(BOOL)animated
{
    cView.frame = self.view.bounds;
    [cView setNeedsDisplay];
}

- (void) viewDidLayoutSubviews
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
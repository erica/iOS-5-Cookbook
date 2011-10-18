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

CGRect rectCenteredInRect(CGRect rect, CGRect mainRect)
{
	return CGRectOffset(rect, 
						CGRectGetMidX(mainRect)-CGRectGetMidX(rect),
						CGRectGetMidY(mainRect)-CGRectGetMidY(rect));
}

@interface BigTextView : UIView
{
	UIFont *textFont;
	CGSize textSize;
	int fontSize;	
}
@property (nonatomic, retain) NSString *string;
+ (void) bigTextWithString:(NSString *)theString;
@end

@implementation BigTextView
@synthesize string;
- (void) drawRect:(CGRect)rect
{
	[super drawRect:rect];
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	// Flip coordinates and inset enough so the status bar isn't an issue
	CGRect flipRect = CGRectMake(0.0f, 0.0f, self.frame.size.height, self.frame.size.width);
	flipRect = CGRectInset(flipRect, 24.0f, 24.0f);
    
	// Iterate until finding a set of font traits that fits this rectangle
	// Thanks for the inspiration from the lovely QuickSilver people
	for(fontSize = 18; fontSize < 300; fontSize++ ) 
	{
		textFont = [UIFont boldSystemFontOfSize:fontSize+1];
		textSize = [string sizeWithFont:textFont];
		if (textSize.width > (flipRect.size.width + ([textFont descender] * 2)))
			break;
	}
	
	// Initialize the string helper to match the traits
	StringHelper *shelper = [StringHelper buildHelper];
	shelper.fontSize = fontSize;
	shelper.foregroundColor = [UIColor whiteColor];
	shelper.alignment = @"Center";
	shelper.fontName = @"GeezaPro-Bold";
	[shelper appendFormat:@"%@", string];
    
	// Establish a frame that encloses the text at the maximum size
	CGRect textFrame = CGRectZero;
	textFrame.size = [string sizeWithFont:[UIFont fontWithName:shelper.fontName size:shelper.fontSize]];
	
	// Center the destination rect within the flipped rectangle
	CGRect centerRect = rectCenteredInRect(textFrame, flipRect);
    
	// Flip coordinates so the text reads the right way
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
    
	// Rotate 90 deg to write text horizontally along window's vertical axis
	CGContextRotateCTM(context, -M_PI_2);
	CGContextTranslateCTM(context, -self.frame.size.height, 0.0f);
	
	// Draw a lovely gray backsplash
	[[UIColor grayColor] set];
	CGRect insetRect = CGRectInset(centerRect, -20.0f, -20.0f);
	[[UIBezierPath bezierPathWithRoundedRect:insetRect cornerRadius:32.0f] fill];
	CGContextFillPath(context);
    
	// Create a path for the text to draw into
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, NULL, centerRect);
	
	// Draw the text
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)shelper.string);
	CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, shelper.string.length), path, NULL);
	CTFrameDraw(theFrame, context);
	
	// Clean up
	CFRelease(framesetter);
	CFRelease(path);
	CFRelease(theFrame);	
}

+ (void) bigTextWithString:(NSString *)theString
{
	UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
	BigTextView *btv = [[BigTextView alloc] initWithFrame:keyWindow.bounds];
	btv.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5f];
	btv.string = theString;
	[keyWindow addSubview:btv];
	
	return;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self removeFromSuperview];
}
@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController

- (void) action: (id) sender
{
	[BigTextView bigTextWithString:@"303-555-1212"];
}

- (void) viewDidAppear:(BOOL)animated
{
	[BigTextView bigTextWithString:@"303-555-1212"];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
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
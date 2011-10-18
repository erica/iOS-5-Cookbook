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

@interface CTView : UIView
@property (nonatomic, strong) NSAttributedString *string;
@end

@implementation CTView
@synthesize string;

- (id) initWithAttributedString: (NSAttributedString *) aString
{
	if (!(self = [super initWithFrame:CGRectZero])) return self;
    
	self.backgroundColor = [UIColor clearColor];
	string = aString;
	
	return self;
}

- (void) drawRect:(CGRect)rect
{
	[super drawRect: rect];
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0); // flip the context
	
	// Slightly inset from the edges of the view
	CGMutablePathRef path = CGPathCreateMutable();
	CGRect insetRect = CGRectInset(self.frame, 100.0f, 80.0f);
	CGPathAddRect(path, NULL, insetRect);
    
	// Draw the text
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.string);
	CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, self.string.length), path, NULL);
	CTFrameDraw(theFrame, context);
	
	CFRelease(framesetter);
	CFRelease(path);
	CFRelease(theFrame);
}
@end

#define BASE_TEXT_SIZE	14.0f

@interface TestBedViewController : UIViewController
{
	StringHelper *stringHelper;
    CTView *ctView;
}
@end

@implementation TestBedViewController
- (void) createText
{
	// Initialize a string helper
	stringHelper = [StringHelper buildHelper];
	
	stringHelper.fontName = @"Futura";
	stringHelper.fontSize = 36.0f;
	stringHelper.foregroundColor = [UIColor blackColor];
	stringHelper.alignment = @"Center";
	[stringHelper appendFormat:@"Basic Attributed Strings\n\n"];
	
	BOOL flip = NO;
	NSString *sourceText = @"When in the Course of human events it becomes necessary for one people to dissolve the political bands which have connected them with another and to assume among the powers of the earth, the separate and equal station to which the Laws of Nature and of Nature's God entitle them, a decent respect to the opinions of mankind requires that they should declare the causes which impel them to the separation.";
	
	stringHelper.fontSize = 18.0f;
	stringHelper.alignment = @"Justified";
	stringHelper.foregroundColor = [UIColor redColor];
	[stringHelper appendFormat:@"WORD BREAK MODE AND COLOR FLIPPING: "];
    
	for (NSString *eachWord in [sourceText componentsSeparatedByString:@" "])
	{
		stringHelper.foregroundColor = flip ? [UIColor grayColor] : [UIColor blackColor];
		[stringHelper appendFormat:@"%@ ", eachWord];
		
		flip = !flip;
	}
	
	[stringHelper appendFormat:@"\n\n"];
	stringHelper.breakMode = @"Character";
	
	stringHelper.foregroundColor = [UIColor redColor];
	[stringHelper appendFormat:@"CHARACTER BREAK MODE: "];
    
	stringHelper.foregroundColor = [UIColor blackColor];
	stringHelper.fontSize = 18.0f;
	sourceText = @"We hold these truths to be self-evident, that all men are created equal, that they are endowed by their Creator with certain unalienable Rights, that among these are Life, Liberty and the pursuit of Happiness. — That to secure these rights, Governments are instituted among Men, deriving their just powers from the consent of the governed, — That whenever any Form of Government becomes destructive of these ends, it is the Right of the People to alter or to abolish it, and to institute new Government, laying its foundation on such principles and organizing its powers in such form, as to them shall seem most likely to effect their Safety and Happiness. Prudence, indeed, will dictate that Governments long established should not be changed for light and transient causes; and accordingly all experience hath shewn that mankind are more disposed to suffer, while evils are sufferable than to right themselves by abolishing the forms to which they are accustomed. But when a long train of abuses and usurpations, pursuing invariably the same Object evinces a design to reduce them under absolute Despotism, it is their right, it is their duty, to throw off such Government, and to provide new Guards for their future security. — Such has been the patient sufferance of these Colonies; and such is now the necessity which constrains them to alter their former Systems of Government. The history of the present King of Great Britain is a history of repeated injuries and usurpations, all having in direct object the establishment of an absolute Tyranny over these States. To prove this, let Facts be submitted to a candid world.";
	[stringHelper appendFormat:@"%@", sourceText];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createText];
    ctView = [[CTView alloc] initWithAttributedString:stringHelper.string];
    ctView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:ctView];
	
	ctView.frame = self.view.bounds;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [ctView setNeedsDisplay];
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
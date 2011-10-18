/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MarkupHelper.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define DESTPATH [NSHomeDirectory() stringByAppendingFormat:@"/Documents/out.pdf"]

@interface TestBedViewController : UIViewController <MFMailComposeViewControllerDelegate>

@end

@implementation TestBedViewController
- (NSArray *) findPageSplitsForString: (NSAttributedString *) theString withPageSize: (CGSize) pageSize
{
    NSInteger stringLength = theString.length;
    NSMutableArray *pages = [NSMutableArray array];

    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) theString);
    
    CFRange baseRange = {0,0};
    CFRange targetRange = {0,0};
    do {
        CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, baseRange, NULL, pageSize, &targetRange);
        baseRange.location += targetRange.length;
        [pages addObject:[NSNumber numberWithInt:targetRange.length]];
    } while(baseRange.location < stringLength);
    
    CFRelease(frameSetter);
    return pages;
}

- (void) dumpToPDFFile: (NSString *) pdfPath
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"txt"];
    NSString *markup = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSAttributedString *attributed = [MarkupHelper stringFromMarkup:markup];

	CGRect theBounds = CGRectMake(0.0f, 0.0f, 640.0f, 480.0f);
    CGRect insetRect = CGRectInset(theBounds, 20.0f, 20.0f);
    
    NSArray *pageSplits = [self findPageSplitsForString:attributed withPageSize:insetRect.size];
    int offset = 0;
    
	UIGraphicsBeginPDFContextToFile(pdfPath, theBounds, nil);
    
    for (NSNumber *pageStart in pageSplits)
    {
        UIGraphicsBeginPDFPage();
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, theBounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, insetRect);
        
        NSRange offsetRange = {offset, [pageStart integerValue]};
        NSAttributedString *subString = [attributed attributedSubstringFromRange:offsetRange];
        offset += offsetRange.length;
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)subString);
        CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, subString.length), path, NULL);
        CTFrameDraw(theFrame, context);
        
        CFRelease(framesetter);
        CFRelease(path);
        CFRelease(theFrame);
    }
    
	UIGraphicsEndPDFContext();
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
		  didFinishWithResult:(MFMailComposeResult)result 
						error:(NSError*)error
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void) email: (id) sender
{
    self.navigationItem.rightBarButtonItem = nil;
	MFMailComposeViewController *mcvc = [[MFMailComposeViewController alloc] init];
	[mcvc setSubject:@"Sample Core Text PDF"];
    
	[mcvc addAttachmentData:[NSData dataWithContentsOfFile:DESTPATH] mimeType:@"image/pdf" fileName:@"output.pdf"];
	
	mcvc.mailComposeDelegate = self;
	mcvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:mcvc animated:YES];	
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self dumpToPDFFile:DESTPATH];
    UIWebView *wv = [[UIWebView alloc] initWithFrame:self.view.bounds];
	[wv loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:DESTPATH]]];
	wv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:wv];
    
    if ([MFMailComposeViewController canSendMail])
		self.navigationItem.rightBarButtonItem = BARBUTTON(@"Go", @selector(email:));
	else 
		self.title = @"Please set up mail";
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
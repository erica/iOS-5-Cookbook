/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define INITPAGES	3

typedef void (^AnimationBlock)(void);
typedef void (^CompletionBlock)(BOOL completed);

@interface TestBedViewController : UIViewController <UIScrollViewDelegate>
{
    UIScrollView *scrollView;
    CGFloat dimension;
    
	IBOutlet UIPageControl *pageControl;
    
	IBOutlet UIButton *addButton;
	IBOutlet UIButton *cancelButton;
	IBOutlet UIButton *confirmButton;
	IBOutlet UIButton *deleteButton;
}
@end

@implementation TestBedViewController

- (void) pageTurn: (UIPageControl *) aPageControl
{
	int whichPage = aPageControl.currentPage;
	[UIView animateWithDuration:0.3f 
					 animations:^{scrollView.contentOffset = CGPointMake(dimension * whichPage, 0.0f);}];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    // Fudge a little and take the floor to accommodate division issues
	pageControl.currentPage = floor((scrollView.contentOffset.x / dimension) + 0.25);
}

- (UIColor *)randomColor
{
	float red = (64 + (random() % 191)) / 256.0f;
	float green = (64 + (random() % 191)) / 256.0f;
	float blue = (64 + (random() % 191)) / 256.0f;
	return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

- (void) layoutPages
{
    int whichPage = pageControl.currentPage;
    
    scrollView.frame = CGRectMake(0.0f, 0.0f, dimension, dimension);
    scrollView.contentSize = CGSizeMake(pageControl.numberOfPages * dimension, dimension);
	scrollView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    
    float offset = 0.0f;
    for (UIView *eachView in scrollView.subviews)
    {
        if (eachView.tag == 999)
        {
            eachView.frame = CGRectMake(offset, 0.0f, dimension, dimension);
            offset += dimension;
        }
    }
    
    scrollView.contentOffset = CGPointMake(dimension * whichPage, 0.0f);
}

- (void) addPage
{
	pageControl.numberOfPages = pageControl.numberOfPages + 1;
	pageControl.currentPage = pageControl.numberOfPages - 1;
    
	UIView *aView = [[UIView alloc] init];
	aView.backgroundColor = [self randomColor];
    aView.tag = 999;
	[scrollView addSubview:aView];
    
    [self layoutPages];
}

- (void) requestAdd: (UIButton *) button
{
	[self addPage];
	addButton.enabled = (pageControl.numberOfPages < 8) ? YES : NO;
	deleteButton.enabled = YES;
	[self pageTurn:pageControl];
}

- (void) deletePage
{
	int whichPage = pageControl.currentPage;
	pageControl.numberOfPages = pageControl.numberOfPages - 1;
    int i = 0;
    for (UIView *eachView in scrollView.subviews)
    {
        if ((i == whichPage) && (eachView.tag == 999))
        {
            [eachView removeFromSuperview];
            break;
        }
        
        if (eachView.tag == 999) i++;
    }
    
    [self layoutPages];
}

- (void) hideConfirmAndCancel
{
	cancelButton.enabled = NO;
	[UIView animateWithDuration:0.3f animations:^(void)
    {
        confirmButton.center = CGPointMake(deleteButton.center.x - 300.0f, deleteButton.center.y);
    }];
}

- (void) confirmDelete: (UIButton *) button
{
	[self deletePage];
	addButton.enabled = YES;
	deleteButton.enabled = (pageControl.numberOfPages > 1) ? YES : NO;
	[self pageTurn:pageControl];
	[self hideConfirmAndCancel];
}

- (void) cancelDelete: (UIButton *) button
{
	[self hideConfirmAndCancel];
}

- (void) requestDelete: (UIButton *) button
{
	// Bring forth the cancel and confirm buttons
	[cancelButton.superview bringSubviewToFront:cancelButton];
	[confirmButton.superview bringSubviewToFront:confirmButton];
	cancelButton.enabled = YES;
	
	// Animate the confirm button into place
	confirmButton.center = CGPointMake(deleteButton.center.x - 300.0f, deleteButton.center.y);
	
	[UIView animateWithDuration:0.3f animations:^(void)
    {
        confirmButton.center = deleteButton.center;
    }];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    
	srandom(time(0));
    
    pageControl.numberOfPages = 0;
	[pageControl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    
	// Create the scroll view and set its content size and delegate
	scrollView = [[UIScrollView alloc] init];
	scrollView.pagingEnabled = YES;
	scrollView.delegate = self;
	[self.view addSubview:scrollView];
    
	// Load in pages
	for (int i = 0; i < INITPAGES; i++)
        [self addPage];    
    pageControl.currentPage = 0;
	
	// Increase the size of the add button
    addButton.frame = CGRectInset(addButton.frame, -20.0f, -20.0f);
}

- (void) viewDidAppear:(BOOL)animated
{
    dimension = MIN(self.view.bounds.size.width, self.view.bounds.size.height) * 0.8f;
    [self layoutPages];
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
	TestBedViewController *tbvc = [[TestBedViewController alloc] initWithNibName:@"TestBedViewController" bundle:[NSBundle mainBundle]];
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
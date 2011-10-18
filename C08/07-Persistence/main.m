/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

#define MAXFLOWERS 12
#define HALFFLOWER	32.0f
#define RANDOMPOINT	CGPointMake(random() % ((int)(self.view.bounds.size.width - 2 * HALFFLOWER)) + HALFFLOWER, random() % ((int)(self.view.bounds.size.height - 2 * HALFFLOWER)) + HALFFLOWER)

@interface DragView : UIImageView
{
    CGPoint previousLocation;
}
@property (nonatomic, strong) NSString *whichFlower;
@end

@implementation DragView
@synthesize whichFlower;

- (id) initWithImage: (UIImage *) anImage
{
    if (self = [super initWithImage:anImage])
    {
        self.userInteractionEnabled = YES;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]; 
        self.gestureRecognizers = [NSArray arrayWithObject: pan];
    }
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Promote the touched view
    [self.superview bringSubviewToFront:self];
    
    // Remember original location
    previousLocation = self.center;
}

- (void) handlePan: (UIPanGestureRecognizer *) uigr
{
	CGPoint translation = [uigr translationInView:self.superview];
	CGPoint newcenter = CGPointMake(previousLocation.x + translation.x, previousLocation.y + translation.y);
	
	// Bound movement into parent bounds
	float halfx = CGRectGetMidX(self.bounds);
	newcenter.x = MAX(halfx, newcenter.x);
	newcenter.x = MIN(self.superview.bounds.size.width - halfx, newcenter.x);
	
	float halfy = CGRectGetMidY(self.bounds);
	newcenter.y = MAX(halfy, newcenter.y);
	newcenter.y = MIN(self.superview.bounds.size.height - halfy, newcenter.y);
	
	// Set new location
	self.center = newcenter;	
}@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (void) updateDefaults
{
	NSMutableArray *colors =  [[NSMutableArray alloc] init];
	NSMutableArray *locs = [[NSMutableArray alloc] init];
	
	for (DragView *dv in [self.view subviews]) 
	{
		[colors addObject:dv.whichFlower];
		[locs addObject:NSStringFromCGRect(dv.frame)];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:colors forKey:@"colors"];
	[[NSUserDefaults standardUserDefaults] setObject:locs forKey:@"locs"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) loadFlowersInView: (UIView *) backdrop
{
	// Attempt to read in previous colors and locations
	NSMutableArray *colors = [[NSUserDefaults standardUserDefaults] objectForKey:@"colors"];
	NSMutableArray *locs = [[NSUserDefaults standardUserDefaults] objectForKey:@"locs"];

    // Add the flowers to random points on the screen	
	for (int i = 0; i < MAXFLOWERS; i++)
	{
		NSString *whichFlower = [[NSArray arrayWithObjects:@"blueFlower.png", @"pinkFlower.png", @"orangeFlower.png", nil] objectAtIndex:(random() % 3)];
		if (colors && ([colors count] == MAXFLOWERS)) whichFlower = [colors objectAtIndex:i];
		
		DragView *dragger = [[DragView alloc] initWithImage:[UIImage imageNamed:whichFlower]];
		dragger.center = RANDOMPOINT;
		dragger.userInteractionEnabled = YES;
		dragger.whichFlower = whichFlower;
		if (locs && ([locs count] == MAXFLOWERS)) dragger.frame = CGRectFromString([locs objectAtIndex:i]);
		
		[backdrop addSubview:dragger];
    }
}

- (void) restart
{
	for (UIView *view in [self.view subviews])
		[view removeFromSuperview];
	
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"colors"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"locs"];
	
	[self loadFlowersInView:self.view];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor blackColor];
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Restart", @selector(restart));
	srandom(time(0));
    
    [self loadFlowersInView:self.view];
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
    TestBedViewController *tbvc;
}
@end
@implementation TestBedAppDelegate
- (void)applicationWillResignActive:(UIApplication *)application
{

	[tbvc updateDefaults];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    [application setStatusBarHidden:YES];
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
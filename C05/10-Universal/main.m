/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#pragma mark Split View Detail Controller
@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate>
{
	UIPopoverController *popoverController;
}
@property (nonatomic, retain) UIPopoverController *popoverController;
@end

@implementation DetailViewController
@synthesize popoverController;

+ (id) controller
{
	DetailViewController *controller = [[DetailViewController alloc] init];
	controller.view.backgroundColor = [UIColor blackColor];
	return controller;
}

// Called upon going into portrait mode, hiding the normal table view
- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)aPopoverController 
{
    barButtonItem.title = aViewController.title;
	self.navigationItem.leftBarButtonItem = barButtonItem;
    self.popoverController = aPopoverController;
}

// Called upon going into landscape mode.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem 
{
	self.navigationItem.leftBarButtonItem = nil;
    self.popoverController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
@end

#pragma mark Table-based Root View Browser
@interface ColorViewController : UITableViewController
@end

@implementation ColorViewController
+ (id) controller
{
	ColorViewController *controller = [[ColorViewController alloc] init];
    controller.title = @"Colors";
	return controller;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"generic"];
	if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"generic"];
	
	cell.textLabel.text = @"Brightness";
	cell.textLabel.textColor = [UIColor colorWithWhite:(indexPath.row / 10.0f) alpha:1.0f];
    cell.accessoryType = IS_IPAD ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (IS_IPAD)
	{
		UIViewController *controller = (UIViewController *)self.splitViewController.delegate;
		controller.view.backgroundColor = cell.textLabel.textColor;
	}
	else 
	{
		DetailViewController *controller = [DetailViewController controller];
		controller.view.backgroundColor = cell.textLabel.textColor;
		[self.navigationController pushViewController:controller animated:YES];
	}
}

- (void) viewDidAppear: (BOOL) animated
{
	self.tableView.rowHeight = 72.0f;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
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
- (UISplitViewController *) splitviewController
{
	// Create the navigation-run root view
	ColorViewController *rootVC = [ColorViewController controller];
	UINavigationController *rootNav = [[UINavigationController alloc] initWithRootViewController:rootVC];
	rootNav.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	
	// Create the navigation-run detail view
	DetailViewController *detailVC = [DetailViewController controller];
	UINavigationController *detailNav = [[UINavigationController alloc] initWithRootViewController:detailVC];
	detailNav.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	
	// Add both to the split view controller
	UISplitViewController *svc = [[UISplitViewController alloc] init];
	svc.viewControllers = [NSArray arrayWithObjects: rootNav, detailNav, nil];
	svc.delegate = detailVC;
	
	return svc;
}

- (UINavigationController *) navWithColorViewController
{
	ColorViewController *colorViewController = [ColorViewController controller];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:colorViewController];
	nav.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    
	return nav;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    [application setStatusBarHidden:YES];
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	if (IS_IPAD)
		window.rootViewController = [self splitviewController];
	else 
		window.rootViewController = [self navWithColorViewController];
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
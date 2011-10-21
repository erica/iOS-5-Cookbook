/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "TreeNode.h"
#import "XMLParser.h"


#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface TextViewController : UIViewController
@property (weak) UITextView *textView;
@end

@implementation TextViewController
@synthesize textView;
- (void) viewDidAppear:(BOOL)animated
{
	textView.frame = self.view.frame;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
	UITextView *theTextView = [[UITextView alloc] initWithFrame:CGRectZero];
	theTextView.frame = [[UIScreen mainScreen] bounds];
	theTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	theTextView.editable = NO;
	theTextView.font = [UIFont fontWithName:@"Futura" size:IS_IPAD ? 36.0f : 18.0f];
	[self.view addSubview:theTextView];
    textView = theTextView;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

+ (id) controllerWithText: (NSString *) theText
{
	TextViewController *dvc = [[self alloc] init];
    printf("%s", (dvc.view) != nil ? "" : ""); // poke view
	dvc.textView.text = theText;
	return dvc;
}
@end


#pragma mark Split View Detail Controller
@interface SplitDetailViewController : TextViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate>
{
	UIPopoverController *popoverController;
}
@property (nonatomic, retain) UIPopoverController *popoverController;
@end

@implementation SplitDetailViewController
@synthesize popoverController;

+ (id) controllerWithText: (NSString *) theText
{
	SplitDetailViewController *controller = [[SplitDetailViewController alloc] init];
    controller.textView.text = theText;
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

#pragma mark Table-based XML Browser
@interface XMLTreeViewController : UITableViewController
@property (strong) TreeNode *root;
@end

@implementation XMLTreeViewController
@synthesize root;

- (id) initWithRoot:(TreeNode *) newRoot
{
	if (self = [super init]) 
	{
		self.root = newRoot;
		if (newRoot.key) self.title = newRoot.key;
	}
	return self;
}

+ (id) controllerWithRoot: (TreeNode *) root
{
	XMLTreeViewController *tvc = [[XMLTreeViewController alloc] initWithRoot:root];
	return tvc;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.root.children count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"generic"];
	if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"generic"];
	TreeNode *child = [[self.root children] objectAtIndex:[indexPath row]];
	cell.textLabel.text = child.key;
	cell.textLabel.font = [UIFont fontWithName:@"Futura" size:IS_IPAD ? 36.0f : 18.0f];
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	if (child.isLeaf && IS_IPAD)
		cell.accessoryType = UITableViewCellAccessoryNone;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	TreeNode *child = [self.root.children objectAtIndex:[indexPath row]];
	if (child.isLeaf && IS_IPAD)
	{
		SplitDetailViewController *dvc = (SplitDetailViewController *)self.splitViewController.delegate;
		dvc.textView.text = child.leafvalue;
		return;
	}
	else if (child.isLeaf) // iPhone/iPod
	{
		TextViewController *dvc = [TextViewController controllerWithText:child.leafvalue];
 		[self.navigationController pushViewController:dvc animated:YES];
		return;
	}
	XMLTreeViewController *tbc = [XMLTreeViewController controllerWithRoot:child];
	[self.navigationController pushViewController:tbc animated:YES];
}

- (void) viewDidAppear: (BOOL) animated
{
	self.tableView.rowHeight = IS_IPAD ? 72.0f : 44.0f;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void) dealloc
{
	self.root = nil;
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
- (UISplitViewController *) splitviewControllerWithRoot: (TreeNode *) root
{
	// Create the navigation-run root view
	XMLTreeViewController *rootVC = [XMLTreeViewController controllerWithRoot:root];
	UINavigationController *rootNav = [[UINavigationController alloc] initWithRootViewController:rootVC];
	
	// Create the navigation-run detail view
	SplitDetailViewController *detailVC = [SplitDetailViewController controllerWithText:@""];
	UINavigationController *detailNav = [[UINavigationController alloc] initWithRootViewController:detailVC];
	
	// Add both to the split view controller
	UISplitViewController *svc = [[UISplitViewController alloc] init];
	svc.viewControllers = [NSArray arrayWithObjects: rootNav, detailNav, nil];
	svc.delegate = detailVC;
	
	return svc;
}

- (UINavigationController *) xmlControllerWithRoot: (TreeNode *) root
{
	// Create the XML view controller
	XMLTreeViewController *xmlViewController = [XMLTreeViewController controllerWithRoot:root];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:xmlViewController];
    
	return nav;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    [application setStatusBarHidden:YES];
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
    TreeNode *root = [[XMLParser sharedInstance] parseXMLFromURL:[NSURL URLWithString:@"http://www.tuaw.com/rss.xml"]];
    
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if (IS_IPAD)
		window.rootViewController  = [self splitviewControllerWithRoot:root];
	else 
		window.rootViewController  = [self xmlControllerWithRoot:root];
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
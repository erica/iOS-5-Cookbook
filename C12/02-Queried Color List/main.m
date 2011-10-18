/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Crayon.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define SYSBARBUTTON(ITEM, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR] 

@interface TestBedViewController : UITableViewController <NSFetchedResultsControllerDelegate, UISearchBarDelegate>
{
	NSManagedObjectContext *context;
	NSFetchedResultsController *fetchedResultsController;
    UISearchBar *searchBar;
    UISearchDisplayController *searchController;
}
@end

@implementation TestBedViewController
- (void) performFetch
{
	// Init a fetch request
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Crayon" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	[fetchRequest setFetchBatchSize:100]; // more than needed for this example
	
	// Apply an ascending sort for the items
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:nil];
	NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
	[fetchRequest setSortDescriptors:descriptors];
    
    // Recover query
	NSString *query = searchBar.text;
	if (query && query.length) fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", query];
	
	// Init the fetched results controller
	NSError *error;
	fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:@"section" cacheName:nil];
    fetchedResultsController.delegate = self;
	if (![fetchedResultsController performFetch:&error])	
		NSLog(@"Error: %@", [error localizedFailureReason]);
}

#pragma mark Color Utility
- (UIColor *) getColor: (NSString *) hexColor
{
	// Convert a hex color string into a UIColor instance
	unsigned int red, green, blue;
	NSRange range;
	range.length = 2;
	range.location = 0;
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
	range.location = 2; 
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
	range.location = 4; 
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];	
	return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green/255.0f) blue:(float)(blue/255.0f) alpha:1.0f];
}

- (void) addColorToDB: (NSString *) colorString
{
	NSError *error; 
	
	// Extract the color/name pair
	NSArray *colorComponents = [colorString componentsSeparatedByString:@"#"];
	if (colorComponents.count != 2) return;
	
	// Store a name/color pair into the database
	Crayon *item = (Crayon *)[NSEntityDescription insertNewObjectForEntityForName:@"Crayon" inManagedObjectContext:context];
	item.color = [colorComponents objectAtIndex:1];
	item.name = [colorComponents objectAtIndex:0];
	item.section = [[item.name substringToIndex:1] uppercaseString];
	if (![context save:&error]) NSLog(@"Error: %@", [error localizedFailureReason]);
}

#pragma mark Table 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return [[fetchedResultsController sections] count];
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
	// Return the title for a given section
	NSArray *titles = [fetchedResultsController sectionIndexTitles];
	if (titles.count <= section) return @"Error";
	return [titles objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)aTableView 
{
    return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:[fetchedResultsController sectionIndexTitles]];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	// Query the titles for the section associated with an index title
	if (title == UITableViewIndexSearch) 
	{
		[self.tableView scrollRectToVisible:searchBar.frame animated:NO];
		return -1;
	}
	return [fetchedResultsController.sectionIndexTitles indexOfObject:title];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [[[fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Retrieve or create a cell
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basic cell"];
	if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"basic cell"];
	
	// Recover object from fetched results
	NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = [managedObject valueForKey:@"name"];
	UIColor *color = [self getColor:[managedObject valueForKey:@"color"]];
	cell.textLabel.textColor = ([[managedObject valueForKey:@"color"] hasPrefix:@"FFFFFF"]) ? [UIColor blackColor] : color;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	// When a row is selected, color the navigation bar accordingly
	NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
	UIColor *color = [self getColor:[managedObject valueForKey:@"color"]];
	self.navigationController.navigationBar.tintColor = color;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return NO; 	// no reordering allowed
}

#pragma mark Search Bar
- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar
{
	[searchBar setText:@""]; 
	[self performFetch];
}

- (void)searchBar:(UISearchBar *)aSearchBar textDidChange:(NSString *)searchText
{
	[self performFetch];
}


#pragma mark Data
- (void) initCoreData
{
	NSError *error;
	
	// Path to sqlite file. 
	NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/colors.sqlite"];
	NSURL *url = [NSURL fileURLWithPath:path];
    BOOL needsBuilding = ![[NSFileManager defaultManager] fileExistsAtPath:path];
	
	// Init the model, coordinator, context
	NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
	NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) 
		NSLog(@"Error: %@", [error localizedFailureReason]);
	else
	{
		context = [[NSManagedObjectContext alloc] init];
		[context setPersistentStoreCoordinator:persistentStoreCoordinator];
	}
    
    // Create the DB from the text file if needed
    if (needsBuilding)
	{
		NSString *pathname = [[NSBundle mainBundle]  pathForResource:@"crayons" ofType:@"txt"];
		NSArray *crayons = 	[[NSString stringWithContentsOfFile:pathname encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
		for (NSString *colorString in crayons) [self addColorToDB:colorString];
	}
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Create a search bar
	searchBar = [[UISearchBar alloc] initWithFrame:(CGRect){0,0,100,44}];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	searchBar.keyboardType = UIKeyboardTypeAlphabet;
	searchBar.delegate = self;
	self.tableView.tableHeaderView = searchBar;
	
	// Create the search display controller
	searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	searchController.searchResultsDataSource = self;
	searchController.searchResultsDelegate = self;
    
    [self initCoreData];
    [self performFetch];
}

- (void) viewDidAppear:(BOOL)animated
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:NO];
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
    [[UISearchBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
     
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
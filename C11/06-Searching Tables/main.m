/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define CRAYON_NAME(CRAYON)	[[CRAYON componentsSeparatedByString:@"#"] objectAtIndex:0]
#define CRAYON_COLOR(CRAYON) getColor([[CRAYON componentsSeparatedByString:@"#"] lastObject])
#define DEFAULTKEYS [crayonColors.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]
#define FILTEREDKEYS [filteredArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]

#define ALPHA	@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"

// Convert a 6-character hex color to a UIColor object
UIColor *getColor(NSString *hexColor)
{
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

@interface TestBedViewController : UITableViewController <UISearchBarDelegate>
{
	NSMutableDictionary *crayonColors;
    NSArray *filteredArray;
    UISearchBar *searchBar;
    UISearchDisplayController *searchController;
    
    NSMutableArray *sectionArray;
}
@end

@implementation TestBedViewController

// Return the letter that starts each section member's text
- (NSString *) firstLetter: (NSInteger) section
{
    return [[ALPHA substringFromIndex:section] substringToIndex:1];
}

// Return an array of items that appear in each section
- (NSArray *) itemsInSection: (NSInteger) section
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF beginswith[cd] %@", [self firstLetter:section]];
    return [crayonColors.allKeys filteredArrayUsingPredicate:predicate];
}

// Return an array of section titles for index
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)aTableView 
{
	if (aTableView == self.tableView)  // regular table
	{
		NSMutableArray *indices = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
		for (int i = 0; i < sectionArray.count; i++)
			if ([[sectionArray objectAtIndex:i] count])
				[indices addObject:[self firstLetter:i]];

        return indices;
	}
	else return nil; // search table
}

// Find the section that corresponds to a given title
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	if (title == UITableViewIndexSearch) 
	{
		[self.tableView scrollRectToVisible:searchBar.frame animated:NO];
		return -1;
	}
	return [ALPHA rangeOfString:title].location;
}

// Return the header title for a section
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
	if (aTableView == self.tableView) 
	{
		if ([[sectionArray objectAtIndex:section] count] == 0) return nil;
		return [NSString stringWithFormat:@"Crayon names starting with '%@'", [self firstLetter:section]];
	}
	else return nil;
}

// Return the number of table sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{ 
    if (aTableView == self.tableView) return sectionArray.count;
    return 1; 
}

// Return the number of rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
	// Normal table
	if (aTableView == self.tableView) 
        return [[sectionArray objectAtIndex:section] count];
	
	// Search table
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchBar.text];
	filteredArray = [crayonColors.allKeys filteredArrayUsingPredicate:predicate];
	return filteredArray.count;
}

// Produce a cell for the given index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Dequeue or create a cell
	UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"BaseCell"];
	if (!cell) 
        cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"] ;  
    
	// Retrieve the crayon and its color
    NSArray *currentItems = [sectionArray objectAtIndex:indexPath.section];
	NSArray *keyCollection = (aTableView == self.tableView) ? currentItems : FILTEREDKEYS;
	NSString *crayon = [keyCollection objectAtIndex:indexPath.row];
    
	cell.textLabel.text = crayon;
	if (![crayon hasPrefix:@"White"])
		cell.textLabel.textColor = [crayonColors objectForKey:crayon];
	else
		cell.textLabel.textColor = [UIColor blackColor];
	return cell;
}

// Respond to user selections by updating tint colors
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSArray *currentItems = [sectionArray objectAtIndex:indexPath.section];
	NSArray *keyCollection = (aTableView == self.tableView) ? currentItems : FILTEREDKEYS;
	NSString *crayon = [keyCollection objectAtIndex:indexPath.row];
    
    UIColor *crayonColor = [crayonColors objectForKey:crayon];
	self.navigationController.navigationBar.tintColor = crayonColor;
	searchBar.tintColor = crayonColor;
}

// Via Jack Lucky. Handle the cancel button by resetting the search text
- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar
{
	[searchBar setText:@""]; 
}

// Upon appearing, scroll away the search bar
- (void) viewDidAppear:(BOOL)animated
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:NO];
}


- (void) loadView
{
    [super loadView];

	// Prepare the crayon color dictionary
	NSString *pathname = [[NSBundle mainBundle]  pathForResource:@"crayons" ofType:@"txt" inDirectory:@"/"];
	NSArray *rawCrayons = [[NSString stringWithContentsOfFile:pathname encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
	crayonColors = [NSMutableDictionary dictionary];
	for (NSString *string in rawCrayons) 
		[crayonColors setObject:CRAYON_COLOR(string) forKey:CRAYON_NAME(string)];
    
    sectionArray = [NSMutableArray array];
    for (int i = 0; i < 26; i++)
        [sectionArray addObject:[self itemsInSection:i]];
    
    // Create a search bar
	searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
	searchBar.tintColor = COOKBOOK_PURPLE_COLOR;
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	searchBar.keyboardType = UIKeyboardTypeAlphabet;
	self.tableView.tableHeaderView = searchBar;
	
	// Create the search display controller
	searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	searchController.searchResultsDataSource = self;
	searchController.searchResultsDelegate = self;
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
/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "ABContactsHelper.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]

@interface TestBedViewController : UITableViewController <ABPersonViewControllerDelegate, UISearchBarDelegate>
{
    NSArray *matches;
    NSArray *filteredArray;
    UISearchBar *searchBar;
    UISearchDisplayController *searchController;
}
@end

@implementation TestBedViewController

// Return the number of table sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{ 
    return 1; 
}

// Return the number of rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
    if (aTableView == self.tableView)
        return matches.count;
    
    matches = [ABContactsHelper contactsMatchingName:searchBar.text];
    matches = [matches sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    return matches.count;
}

// Produce a cell for the given index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Dequeue or create a cell
	UITableViewCellStyle style =  UITableViewCellStyleSubtitle;
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"BaseCell"];
	if (!cell) 
        cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    
    ABContact *contact = [matches objectAtIndex:indexPath.row];
    cell.textLabel.text = contact.compositeName;
    cell.detailTextLabel.text = contact.phonenumbers;

    CGSize small = CGSizeMake(48.0f, 48.0f);
    UIGraphicsBeginImageContext(small);
    UIImage *image = contact.image;
    if (image)
        [image drawInRect:(CGRect){.size = small}];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
	return cell;
}

- (BOOL)personViewController: (ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
    // Reveal the item that was selected
    if ([ABContact propertyIsMultiValue:property])
    {
        NSArray *array = [ABContact arrayForProperty:property inRecord:person];
        NSLog(@"%@", [array objectAtIndex:identifierForValue]);
    }
    else
    {
        id object = [ABContact objectForProperty:property inRecord:person];
        NSLog(@"%@", [object description]);
    }
    
    return NO;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ABContact *contact = [matches objectAtIndex:indexPath.row];
    ABPersonViewController *pvc = [[ABPersonViewController alloc] init];
    pvc.displayedPerson = contact.record;
    pvc.personViewDelegate = self;
    pvc.allowsEditing = YES; // optional editing
    [self.navigationController pushViewController:pvc animated:YES];
}

// Via Jack Lucky. Handle the cancel button by resetting the search text
- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar
{
    NSLog(@"Restoring contacts");
    matches = [ABContactsHelper contacts];
    matches = [matches sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    [self.tableView reloadData];
}

- (void) loadView
{
    [super loadView];

    // Create a search bar
	searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
	searchBar.tintColor = COOKBOOK_PURPLE_COLOR;
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	searchBar.keyboardType = UIKeyboardTypeAlphabet;
    searchBar.delegate = self;
	self.tableView.tableHeaderView = searchBar;
    
    self.tableView.rowHeight = 50.0f;
	
	// Create the search display controller
	searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	searchController.searchResultsDataSource = self;
	searchController.searchResultsDelegate = self;
    
    // Normal table
    matches = [ABContactsHelper contacts];
    matches = [matches sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
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
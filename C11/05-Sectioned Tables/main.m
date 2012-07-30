/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define CRAYON_NAME(CRAYON)	[[CRAYON componentsSeparatedByString:@"#"] objectAtIndex:0]
#define CRAYON_COLOR(CRAYON) getColor([[CRAYON componentsSeparatedByString:@"#"] lastObject])
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

@interface TestBedViewController : UITableViewController
{
	NSMutableDictionary *crayonColors;
    NSMutableArray *sectionArray;
}
@end

@implementation TestBedViewController


// Return an array of section titles for index
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)aTableView 
{
    NSMutableArray *indices = [NSMutableArray array];
    for (int i = 0; i < sectionArray.count; i++)
        if ([[sectionArray objectAtIndex:i] count])
            [indices addObject:[self firstLetter:i]];
    
		// [indices addObject:@"\ue057"]; // <-- using emoji
		
    return indices;
}

// Find the section that corresponds to a given title
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return [ALPHA rangeOfString:title].location;
}

// Return the header title for a section
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    if ([[sectionArray objectAtIndex:section] count] == 0) return nil;
    return [NSString stringWithFormat:@"Crayon names starting with '%@'", [self firstLetter:section]];
}

// Return the number of table sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{ 
    return sectionArray.count;
}

// Return the number of rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
    return [[sectionArray objectAtIndex:section] count];
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
	NSString *crayon = [currentItems objectAtIndex:indexPath.row];
    
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
	NSString *crayon = [currentItems objectAtIndex:indexPath.row];
    
    UIColor *crayonColor = [crayonColors objectForKey:crayon];
	self.navigationController.navigationBar.tintColor = crayonColor;
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
/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define NUMSTR(_aNumber_) [NSString stringWithFormat:@"%d", _aNumber_]

@interface NSMutableDictionary (Boolean)
- (BOOL) boolForKey: (NSString *) aKey;
- (void) setBool: (BOOL) boolValue ForKey: (NSString *) aKey;
@end

@implementation NSMutableDictionary (Boolean)
- (BOOL) boolForKey: (NSString *) aKey
{
    if (![self objectForKey:aKey]) return NO;
    
    id obj = [self objectForKey:aKey];
    
    if ([obj respondsToSelector:@selector(boolValue)])
        return [(NSNumber *)obj boolValue];
    
    return NO;
}

- (void) setBool: (BOOL) boolValue ForKey: (NSString *) aKey
{
    [self setObject:[NSNumber numberWithBool:boolValue] forKey:aKey];
}
@end

@interface TestBedViewController : UITableViewController
{
    NSArray *items;
    NSMutableDictionary *switchStates;
}
@end

@implementation TestBedViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{ 
	// This simple table has only one section
	return 1; 
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
	// Return the number of items
	return items.count;
}

- (void) toggleSwitch: (UISwitch *) aSwitch
{
    // Store the state for the active switch
    [switchStates setBool:aSwitch.isOn ForKey:NUMSTR(aSwitch.superview.tag)];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Use the built-in nib loader
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"CustomCell"];

    // Retrieve the switch and add a target if needed
    UISwitch *switchView = (UISwitch *)[cell viewWithTag:99];
    if (![switchView allTargets].count)
        [switchView addTarget:self action:@selector(toggleSwitch:) forControlEvents:UIControlEventValueChanged];
    
	cell.textLabel.text = [items objectAtIndex:indexPath.row];
    
    // Comment this out to see "wrong" behavior
    switchView.on = [switchStates boolForKey:NUMSTR(indexPath.row)];
    
    // Label the cell's content view, so it can be recovered from the switch
    cell.contentView.tag = indexPath.row;
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // Respond to user interaction
    self.title = [items objectAtIndex:indexPath.row];
}

- (void) loadView
{
    [super loadView];
    items = [@"A*B*C*D*E*F*G*H*I*J*K*L*M*N*O*P*Q*R*S*T*U*V*W*X*Y*Z" componentsSeparatedByString:@"*"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CustomCell"];
    
    self.tableView.backgroundColor = [UIColor clearColor];

    switchStates = [NSMutableDictionary dictionary];
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
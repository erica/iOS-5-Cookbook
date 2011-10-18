/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Department.h"
#import "Person.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define SYSBARBUTTON(ITEM, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR] 

@interface TestBedViewController : UIViewController <NSFetchedResultsControllerDelegate>
{
    NSManagedObjectContext *context;
    NSFetchedResultsController *fetchedResultsController;
    Department __block *department;
    
    UIToolbar *tb;
}
@end

@implementation TestBedViewController
- (void) fetchPeople
{
    // Create a basic fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Person" inManagedObjectContext:context]];
    
    // Add a sort descriptor
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:nil];
    NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:descriptors];
    
    // Init the fetched results controller
    NSError __autoreleasing *error;
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:@"Root"];
    if (![fetchedResultsController performFetch:&error])    
        NSLog(@"Error: %@", [error localizedFailureReason]);
}

- (void) listPeople
{
    if (!fetchedResultsController.fetchedObjects.count) 
    {
        NSLog(@"Database has no people at this time");
        return;
    }
    
    for (Person *person in fetchedResultsController.fetchedObjects)    
        NSLog(@"PERSON %@ : %@", person.name, person.department.groupName);
}

- (void) addObjects
{
    // Insert objects for department and several people, setting their properties
    for (NSString *name in [@"John Smith*Jane Doe*Fred Wilkins*Emma Smith*Betty Franklin" componentsSeparatedByString:@"*"])    
    {
        NSLog(@"Adding %@", name);
        Person *person = (Person *)[NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:context];
        person.name = name;
        person.birthday = [NSDate date];
        person.department = department;
    }
    
    // Save the data
    NSError __autoreleasing *error;        
    if (![context save:&error]) 
        NSLog(@"Error: %@", [error localizedFailureReason]);
    
    [self fetchPeople];
}

- (void) removePeople
{
    
    // remove all people (if they exist)
    if (!fetchedResultsController.fetchedObjects.count) 
    {
        NSLog(@"No people to remove.");
        return;
    }
    
    NSLog(@"Removing people");
    
    // remove each person
    for (Person *person in fetchedResultsController.fetchedObjects)    
    {
        NSLog(@"Deleting %@", person.name);
        [context deleteObject:person];            
    }
    
    // Save the data
    NSError __autoreleasing *error;        
    if (![context save:&error]) 
        NSLog(@"Error: %@", [error localizedFailureReason]);
    
    [self fetchPeople];
    [self listPeople];
}


- (void) initCoreData
{
    NSError *error;
    
    // Path to data file. 
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/data.db"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
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
    
    
    // Create a basic fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Department" inManagedObjectContext:context]];
    
    // Add a sort descriptor
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"groupName" ascending:YES selector:nil];
    NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:descriptors];
    
    // Search for departments.
    NSFetchedResultsController __block *fetched;
    fetched = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:@"Dept"];
    if (![fetched performFetch:&error])    
        NSLog(@"Error: %@", [error localizedFailureReason]);
    
    // Create a new department if it is not found
    if (!fetched.fetchedObjects.count)
    {
        NSLog(@"Initializing the Department");
        department = (Department *)[NSEntityDescription insertNewObjectForEntityForName:@"Department" inManagedObjectContext:context];
        department.groupName = @"Office of Personnel Management";
    }
    else
        department = [fetched.fetchedObjects lastObject];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];    

    [self initCoreData];
    
    NSMutableArray *items = [NSMutableArray array];
    [items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
    [items addObject:BARBUTTON(@"List", @selector(listPeople))];
    [items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
    [items addObject:BARBUTTON(@"Add", @selector(addObjects))];
    [items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
    [items addObject:BARBUTTON(@"Remove", @selector(removePeople))];
    [items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
    
    tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    tb.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tb.items = items;
    self.navigationItem.titleView = tb;
}

- (void) viewDidAppear:(BOOL)animated
{
    tb.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f);
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
    [[UIToolbar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
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
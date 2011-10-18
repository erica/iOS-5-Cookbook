/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ToDoItem.h"

#define COOKBOOK_PURPLE_COLOR    [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR)     [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define SYSBARBUTTON(ITEM, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR] 

@interface TestBedViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
    NSManagedObjectContext *context;
    NSFetchedResultsController *fetchedResultsController;
    
    UIToolbar *toolbar;
}
@end

@implementation TestBedViewController
- (void) setBarButtonItems
{
    NSMutableArray *items = [NSMutableArray array];
    UIBarButtonItem *spacer = SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil);

    [items addObject:SYSBARBUTTON(UIBarButtonSystemItemAdd, @selector(add))];
    [items addObject:spacer];

    UIBarButtonItem *undo = SYSBARBUTTON(UIBarButtonSystemItemUndo, @selector(undo));
    undo.enabled = context.undoManager.canUndo;
    [items addObject:undo];
    [items addObject:spacer];
    
    UIBarButtonItem *redo = SYSBARBUTTON(UIBarButtonSystemItemRedo, @selector(redo));
    redo.enabled = context.undoManager.canRedo;
    [items addObject:redo];
    [items addObject:spacer];
    
    UIBarButtonItem *item;
    int count = [[fetchedResultsController fetchedObjects] count];
    if (self.tableView.isEditing)
        item = SYSBARBUTTON(UIBarButtonSystemItemDone, @selector(leaveEditMode));
    else
    {
        item = SYSBARBUTTON(UIBarButtonSystemItemEdit, @selector(enterEditMode));
        item.enabled = (count != 0);
    }

    [items addObject:item];
    
    toolbar.items = items;
}

- (void) undo
{
    [context.undoManager undo];
    [self setBarButtonItems];
}

- (void) redo
{
    [context.undoManager redo];
    [self setBarButtonItems];
}


- (void) performFetch
{
    // Init a fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ToDoItem" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:100]; // more than needed for this example
    
    // Apply an ascending sort for the items
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"action" ascending:YES selector:nil];
    NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:descriptors];
    
    // Init the fetched results controller
    NSError *error;
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:@"sectionName" cacheName:nil];
    fetchedResultsController.delegate = self;
    if (![fetchedResultsController performFetch:&error])    
        NSLog(@"Error: %@", [error localizedFailureReason]);
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView reloadData];
    [self setBarButtonItems];
}

#pragma mark Table Sections
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

#pragma mark Items in Sections
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
    cell.textLabel.text = [managedObject valueForKey:@"action"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
    // some action here
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return NO;     // no reordering allowed
}

#pragma mark Data
-(void)enterEditMode
{
    // Start editing
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self.tableView setEditing:YES animated:YES];
    [self setBarButtonItems];
}

-(void)leaveEditMode
{
    // finish editing
    [self.tableView setEditing:NO animated:YES];
    [self setBarButtonItems];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [context.undoManager beginUndoGrouping];
    
    // delete request
    if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
        NSError *error = nil;
        [context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
        if (![context save:&error]) NSLog(@"Error: %@", [error localizedFailureReason]);
    }
    
    [context.undoManager endUndoGrouping];
    [context.undoManager setActionName:@"Delete"];

    [self performFetch];    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) return;
    
    NSString *todoAction = [alertView textFieldAtIndex:0].text;
    if (!todoAction || todoAction.length == 0) return;
    
    [context.undoManager beginUndoGrouping];
    
    ToDoItem *item = (ToDoItem *)[NSEntityDescription insertNewObjectForEntityForName:@"ToDoItem" inManagedObjectContext:context];
    item.action = todoAction;
    item.sectionName = [[todoAction substringToIndex:1] uppercaseString];
    
    // save the new item
    NSError *error; 
    if (![context save:&error]) NSLog(@"Error: %@", [error localizedFailureReason]);
    
    [context.undoManager endUndoGrouping];
    [context.undoManager setActionName:@"Add"];
    
    [self performFetch];
}

- (void) add
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"To Do" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    [av show];
}

- (void) initCoreData
{
    NSError *error;
    
    // Path to sqlite file. 
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/todo.sqlite"];
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
    
    context.undoManager = [[NSUndoManager alloc] init];
    context.undoManager.levelsOfUndo = 999;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 44.0f)];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.navigationItem.titleView = toolbar;
        
    [self initCoreData];
    [self performFetch];
    [self setBarButtonItems];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
    
    toolbar.frame = CGRectMake(0.0f,0.0f,self.view.frame.size.width, 44.0f);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self resignFirstResponder];
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
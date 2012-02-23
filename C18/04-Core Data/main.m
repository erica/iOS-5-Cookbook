/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ToDoItem.h"
#import "CloudHelper.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define SYSBARBUTTON(ITEM, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR] 

@interface TestBedViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
    UIManagedDocument *document;
	NSManagedObjectContext *context;
	NSFetchedResultsController *fetchedResultsController;
    NSFileCoordinator *coordinator;
}
@end

@implementation TestBedViewController
- (void) setBarButtonItems
{
	// left item is always add
	self.navigationItem.leftBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemAdd, @selector(add));
	
	// right (edit/done) item depends on both edit mode and item count
	int count = [[fetchedResultsController fetchedObjects] count];
	if (self.tableView.isEditing)
		self.navigationItem.rightBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemDone, @selector(leaveEditMode));
	else
		self.navigationItem.rightBarButtonItem =  count ? SYSBARBUTTON(UIBarButtonSystemItemEdit, @selector(enterEditMode)) : nil;
}

- (void) performFetch
{
    [context performBlockAndWait:^(){
        // Init a fetch request
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ToDoItem" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:999]; // more than needed for this example
        
        // Apply an ascending sort for the items
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"action" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
        [fetchRequest setSortDescriptors:descriptors];
        
        // Init the fetched results controller
        NSError *error;
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:@"sectionName" cacheName:nil];
        fetchedResultsController.delegate = self;
        if (![fetchedResultsController performFetch:&error])	
            NSLog(@"Fetch Error: %@", [error localizedDescription]);
    }];
    
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
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return NO; 	// no reordering allowed
}

#pragma mark Edit Mode
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

#pragma mark Handle DB Updates -- both add and delete

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
	// delete request
    if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
        [context performBlockAndWait:^() {
            [context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
        }];
        [self performFetch];
	}
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) return;
    
    NSString *todoAction = [alertView textFieldAtIndex:0].text;
	if (!todoAction || todoAction.length == 0) return;
    
    // Add new item
    [context performBlockAndWait:^() {
        ToDoItem *item = (ToDoItem *)[NSEntityDescription insertNewObjectForEntityForName:@"ToDoItem" inManagedObjectContext:context];
        item.action = todoAction;
        item.sectionName = [[todoAction substringToIndex:1] uppercaseString];
    }];
    [self performFetch];
}

- (void) add
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"To Do" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    [av show];
}

#pragma mark Initialize the Core Data Stores

#define SharedFileName          @"ToDo"
#define PrivateName             @"com.sadun.coredata.basicsample"

- (void) initCoreData
{
    NSURL *localURL = [CloudHelper localFileURL:SharedFileName];
    NSURL *cloudURL = [CloudHelper ubiquityDataFileURL:PrivateName];

    // Create the document pointing to the local sandbox
    document = [[UIManagedDocument alloc] initWithFileURL:localURL];

    // Set the persistent store options to point to the cloud
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             PrivateName, NSPersistentStoreUbiquitousContentNameKey, 
                             cloudURL, NSPersistentStoreUbiquitousContentURLKey, 
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, 
                             nil];
    context = document.managedObjectContext;
    document.persistentStoreOptions = options;
    
    // Register as presenter
    coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:document];
    [NSFileCoordinator addFilePresenter:document];

    // Check at the local sandbox
    if ([CloudHelper isLocal:SharedFileName])
    {
        NSLog(@"Attempting to open existing file");
        [document openWithCompletionHandler:^(BOOL success){
            if (!success) {NSLog(@"Error opening file"); return;}
            NSLog(@"File opened");
            
            [self performFetch];;            
        }];
    }
    else 
    {
        NSLog(@"Creating file.");
        // 1. save it out, 2. close it, 3. read it back in.
        [document saveToURL:localURL 
           forSaveOperation:UIDocumentSaveForCreating 
          completionHandler:^(BOOL success){
              if (!success) { NSLog(@"Error creating file"); return; }
              NSLog(@"File created");
              [document closeWithCompletionHandler:^(BOOL success){
                  NSLog(@"Closed new file: %@", success ? @"Success" : @"Failure");
                  
                  [document openWithCompletionHandler:^(BOOL success){
                      if (!success) {NSLog(@"Error opening file for reading."); return;}
                      NSLog(@"File opened for reading.");
                      [self performFetch];;
                  }];
              }];            
          }];
    }
    
    // subscribe to the NSPersistentStoreDidImportUbiquitousContentChangesNotification notification
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentStateChanged:) name:UIDocumentStateChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentContentsDidUpdate:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:nil];
}

#pragma mark Courtesy of Apple. Thank you Apple

// Merge the iCloud changes into the managed context
- (void)mergeiCloudChanges:(NSDictionary*)userInfo forContext:(NSManagedObjectContext*)managedObjectContext 
{
    @autoreleasepool 
    {
        NSLog(@"Merging changes from cloud");
        
        NSMutableDictionary *localUserInfo = [NSMutableDictionary dictionary];
        
        NSSet *allInvalidations = [userInfo objectForKey:NSInvalidatedAllObjectsKey];
        NSString *materializeKeys[] = { NSDeletedObjectsKey, NSInsertedObjectsKey };
        
        if (nil == allInvalidations) 
        {
            
            // (1) we always materialize deletions to ensure delete propagation happens correctly, especially with 
            // more complex scenarios like merge conflicts and undo.  Without this, future echoes may 
            // erroreously resurrect objects and cause dangling foreign keys
            // (2) we always materialize insertions to make new entries visible to the UI
            
            int c = (sizeof(materializeKeys) / sizeof(NSString *));
            for (int i = 0; i < c; i++) 
            {
                NSSet *set = [userInfo objectForKey:materializeKeys[i]];
                if ([set count] > 0) 
                {
                    NSMutableSet *objectSet = [NSMutableSet set];
                    for (NSManagedObjectID *moid in set)
                        [objectSet addObject:[managedObjectContext objectWithID:moid]];
                    
                    [localUserInfo setObject:objectSet forKey:materializeKeys[i]];
                }
            }
            
            // (3) we do not materialize updates to objects we are not currently using
            // (4) we do not materialize refreshes to objects we are not currently using
            // (5) we do not materialize invalidations to objects we are not currently using
            
            NSString *noMaterializeKeys[] = { NSUpdatedObjectsKey, NSRefreshedObjectsKey, NSInvalidatedObjectsKey };
            c = (sizeof(noMaterializeKeys) / sizeof(NSString*));
            for (int i = 0; i < 2; i++) 
            {
                NSSet *set = [userInfo objectForKey:noMaterializeKeys[i]];
                if ([set count] > 0) 
                {
                    NSMutableSet *objectSet = [NSMutableSet set];
                    for (NSManagedObjectID *moid in set) 
                    {
                        NSManagedObject *realObj = [managedObjectContext objectRegisteredForID:moid];
                        if (realObj)
                            [objectSet addObject:realObj];
                    }
                    
                    [localUserInfo setObject:objectSet forKey:noMaterializeKeys[i]];
                }
            }
            
            NSNotification *fakeSave = [NSNotification notificationWithName:NSManagedObjectContextDidSaveNotification object:self userInfo:localUserInfo];
            [managedObjectContext mergeChangesFromContextDidSaveNotification:fakeSave]; 
            
        } 
        else 
            [localUserInfo setObject:allInvalidations forKey:NSInvalidatedAllObjectsKey];
        
        [managedObjectContext processPendingChanges];
        
        [self performSelectorOnMainThread:@selector(performFetch) withObject:nil waitUntilDone:NO];
    }
}

- (void) documentContentsDidUpdate: (NSNotification *) notification
{
    NSLog(@"Document Contents Updated.");

    NSDictionary *userInfo = notification.userInfo;
    [context performBlock:^{[self mergeiCloudChanges:userInfo forContext:context];}];
}

- (void)documentStateChanged: (NSNotification *)notification
{
    NSLog(@"Document state change: %@", [CloudHelper documentState:document.documentState]);
    
    UIDocumentState documentState = document.documentState;
    if (documentState & UIDocumentStateInConflict) 
    {
        // This application uses a basic newest version wins conflict resolution strategy
        NSURL *documentURL = document.fileURL;
        NSArray *conflictVersions = [NSFileVersion unresolvedConflictVersionsOfItemAtURL:documentURL];
        for (NSFileVersion *fileVersion in conflictVersions) {
            fileVersion.resolved = YES;
        }
        [NSFileVersion removeOtherVersionsOfItemAtURL:documentURL error:nil];
    }
}

#pragma mark View
- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initCoreData];
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
    // [application setStatusBarHidden:YES];
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
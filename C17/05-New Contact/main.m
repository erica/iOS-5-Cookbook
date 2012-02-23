/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ABContact.h"
#import "ABContactsHelper.h"
#import "ABStandin.h"
#import "ModalAlertDelegate.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface TestBedViewController : UIViewController <ABNewPersonViewControllerDelegate, ABPeoplePickerNavigationControllerDelegate>
@end

@implementation TestBedViewController

- (BOOL) ask: (NSString *) aQuestion
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:aQuestion message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil];
    ModalAlertDelegate *delegate = [ModalAlertDelegate delegateWithAlert:alertView];
    int response = [delegate show];
    return response;
}


#pragma mark NEW PERSON DELEGATE METHODS
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
	if (person)
	{
		ABContact *contact = [ABContact contactWithRecord:person];
		self.title = [NSString stringWithFormat:@"Added %@", contact.compositeName];

        NSError *error;
		BOOL success = [ABContactsHelper addContact:contact withError:&error];
        if (!success)
        {
            NSLog(@"Could not add contact. %@", error.localizedFailureReason);
            self.title = @"Error.";
		}
        
        [ABStandin save:nil];
	}
	else
		self.title = @"Cancelled";
    
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark PEOPLE PICKER DELEGATE METHODS
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	[self dismissModalViewControllerAnimated:YES];
	ABContact *contact = [ABContact contactWithRecord:person];

    NSString *query = [NSString stringWithFormat:@"Really delete %@?",  contact.compositeName];
    if ([self ask:query])
	{
		self.title = [NSString stringWithFormat:@"Deleted %@", contact.compositeName];
		[contact removeSelfFromAddressBook:nil];
        [ABStandin save:nil];
	}

	return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
	// required method that is never called in the people-only-picking
	[self dismissModalViewControllerAnimated:YES];
	return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void) add
{
	// create a new view controller
	ABNewPersonViewController *npvc = [[ABNewPersonViewController alloc] init];
	
	// Create a new contact
	ABContact *contact = [ABContact contact];
	npvc.displayedPerson = contact.record;
	
	// Set delegate
	npvc.newPersonViewDelegate = self;
	
	[self.navigationController pushViewController:npvc animated:YES];
}

- (void) remove
{
	ABPeoplePickerNavigationController *ppnc = [[ABPeoplePickerNavigationController alloc] init];
	ppnc.peoplePickerDelegate = self;
	[self presentModalViewController:ppnc animated:YES];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Add", @selector(add));
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Remove", @selector(remove));
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
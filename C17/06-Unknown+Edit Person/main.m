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

@interface TestBedViewController : UIViewController <ABUnknownPersonViewControllerDelegate, ABPersonViewControllerDelegate>
@end

@implementation TestBedViewController

- (BOOL) ask: (NSString *) aQuestion
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:aQuestion message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil];
    ModalAlertDelegate *delegate = [ModalAlertDelegate delegateWithAlert:alertView];
    int response = [delegate show];
    return response;
}


#pragma mark Unknown Person Delegate Methods
- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownPersonView didResolveToPerson:(ABRecordRef)person
{
    // Handle cancel events
    if (!person) return;
    
    ABPersonViewController *abpvc = [[ABPersonViewController alloc] init];
    abpvc.displayedPerson = person;
    abpvc.allowsEditing = YES;
    abpvc.personViewDelegate = self;
    
    [self.navigationController pushViewController:abpvc animated:YES];
}

- (BOOL)unknownPersonViewController:(ABUnknownPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return YES;
}

#pragma mark PERSON DELEGATE
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
    return NO;
}

#pragma mark Action

- (NSString *) randomPhone
{
    NSString *phone = [NSString stringWithFormat:@"%d%d%d-%d%d%d-%04d",
                       2 + (rand() % 8), (rand() % 10), 1 + (rand() % 9),
                       2 + (rand() % 8), (rand() % 10), 1 + (rand() % 9),
                       rand() % 10000];
    NSLog(@"Phone Number: %@", phone);
    return phone;
}

- (void) addPhone
{
    ABUnknownPersonViewController *upvc = [[ABUnknownPersonViewController alloc] init];
    upvc.unknownPersonViewDelegate = self;
    
    ABContact *contact = [ABContact contact];
    NSString *phone = [self randomPhone];
    [contact addPhoneItem:phone withLabel:kABOtherLabel];
    
    upvc.allowsActions = NO;
    upvc.allowsAddingToAddressBook = YES;
    upvc.message = @"Your new phone number is ready. What now?";
    upvc.displayedPerson = contact.record;
    
    [self.navigationController pushViewController:upvc animated:YES];
}

- (void) call
{
    ABUnknownPersonViewController *upvc = [[ABUnknownPersonViewController alloc] init];
    upvc.unknownPersonViewDelegate = self;
    
    ABContact *contact = [ABContact contact];
    NSString *phone = [self randomPhone];
    [contact addPhoneItem:phone withLabel:kABOtherLabel];
    
    upvc.allowsActions = YES; 
    upvc.allowsAddingToAddressBook = NO; 
    upvc.message = @"Contact Us Now!"; 
    upvc.displayedPerson = contact.record;
    
    [self.navigationController pushViewController:upvc animated:YES];
}

- (void) loadView
{
    srand(time(0));
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Phone", @selector(addPhone));
    self.navigationItem.leftBarButtonItem = BARBUTTON(@"Call", @selector(call));
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
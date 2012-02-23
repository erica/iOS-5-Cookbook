/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "ABStandin.h"
#import "ABContactsHelper.h"
#import "FakePerson.h"

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface TestBedViewController : UIViewController
{
    UITextView *textView;
}
@end

@implementation TestBedViewController

- (void) listContacts
{
    printf("\n\n");
    NSLog(@"Contacts");
    for (ABContact *contact in [ABContactsHelper contacts])
        NSLog(@"%@ %@ %@", contact.firstname, contact.lastname, contact.phonenumbers);
}

- (void) action: (id) sender
{
    ABContact *contact = [FakePerson randomPerson];
    [ABContactsHelper addContact:contact withError:nil];
    [ABStandin save:nil];
    [self listContacts];
}

- (ABContact *) buildSnigglebottom
{
    ABContact *contact = [ABContact contact];
    contact.firstname = @"Henry";
    contact.middlename = @"P";
    contact.lastname = @"Snigglebottom";
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterShortStyle;
    NSString *birthday = @"05/01/1955";
    contact.birthday = [formatter dateFromString:birthday];

    NSError *error;
    BOOL success = [ABContactsHelper addContact:contact withError:&error];
    if (!success)
    {
        NSLog(@"Error adding contact : %@", error);
        return nil;
    }

    return contact;
}

// Keep randomly adding attributes to Henry Snigglebottom
- (void) sniggle
{
    ABContact *person = nil;
    NSArray *matches = [ABContactsHelper contactsMatchingName:@"Snigglebottom"];
    if (matches.count)
        person = [matches objectAtIndex:0];
    else
    {
        person = [self buildSnigglebottom];
        if (!person) return;
    }


    // About to add address, e-mail, phone number, website
    BOOL success;
    NSDictionary *identity = [FakePerson fetchIdentity];    
    NSDictionary *address = [ABContact addressWithStreet:IDVALUE(@"street1") 
                                                withCity:IDVALUE(@"city") 
                                               withState:IDVALUE(@"state") 
                                                 withZip:IDVALUE(@"zip")
                                             withCountry:IDVALUE(@"country_code") 
                                                withCode:nil];
    success = [person addAddressItem:address withLabel:kABHomeLabel];
    NSLog(@"Added address: %@", success ? @"Success" : @"Fail");
    
    success = [person addEmailItem:IDVALUE(@"email_address") withLabel:kABWorkLabel];
    NSLog(@"Added email: %@", success ? @"Success" : @"Fail");
    
    success = [person addPhoneItem:IDVALUE(@"phone_number") withLabel:kABPersonPhoneMobileLabel];
    NSLog(@"Added phone: %@", success ? @"Success" : @"Fail");
    
    success = [person addURLItem:IDVALUE(@"domain") withLabel:kABPersonHomePageLabel];
    NSLog(@"Added email: %@", success ? @"Success" : @"Fail");    
    
    NSError *error;
    if (![ABStandin save:&error])
    {
        NSLog(@"Error saving address book: %@", error.localizedFailureReason);
        return;
    }
    
    textView.text = [[person dictionaryRepresentation] description];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
    self.navigationItem.leftBarButtonItem = BARBUTTON(@"Sniggle", @selector(sniggle));
    
    textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.editable = NO;
    [self.view addSubview:textView];
    
    // Initialize
    [ABStandin load];
}

- (void) viewDidAppear:(BOOL)animated
{
    textView.frame = self.view.bounds;
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

- (void) applicationDidBecomeActive:(UIApplication *)application
{
    [ABContactsHelper refresh];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    // [application setStatusBarHidden:YES];
    [[UINavigationBar appearance] setTintColor: COOKBOOK_PURPLE_COLOR];

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
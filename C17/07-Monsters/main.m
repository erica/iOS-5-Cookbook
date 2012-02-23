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

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPAD    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define IMAGEFILE(BASEFILE, MAXNUM) [NSString stringWithFormat:BASEFILE, (rand() % MAXNUM) + 1]

@interface TestBedViewController : UIViewController <ABUnknownPersonViewControllerDelegate, ABPersonViewControllerDelegate>
@end

@implementation TestBedViewController

// Graphics from: http://www.splitbrain.org/go/monsterid
- (UIImage *) randomImage
{
    // Build a random image based on the monster id art
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 120.0f, 120.0f);
    UIGraphicsBeginImageContext(CGSizeMake(120.0f, 120.0f));
    
    UIImage *part;
    part = [UIImage imageNamed:IMAGEFILE(@"oldarms_%d.png", 5)];
    [part drawInRect:rect];
    part = [UIImage imageNamed:IMAGEFILE(@"oldlegs_%d.png", 5)];
    [part drawInRect:rect];
    part = [UIImage imageNamed:IMAGEFILE(@"oldbody_%d.png", 15)];
    [part drawInRect:rect];
    part = [UIImage imageNamed:IMAGEFILE(@"oldmouth_%d.png", 10)];
    [part drawInRect:rect];
    part = [UIImage imageNamed:IMAGEFILE(@"oldeyes_%d.png", 15)];
    [part drawInRect:rect];
    part = [UIImage imageNamed:IMAGEFILE(@"oldhair_%d.png", 5)];
    [part drawInRect:rect];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
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

- (void) addAvatar
{
    ABUnknownPersonViewController *upvc = [[ABUnknownPersonViewController alloc] init];
    upvc.unknownPersonViewDelegate = self;
    
    ABContact *contact = [ABContact contact];
    contact.image = [self randomImage];

    upvc.allowsActions = NO;
    upvc.allowsAddingToAddressBook = YES;
    upvc.message = @"Who looks like this?";
    upvc.displayedPerson = contact.record;
    
    [self.navigationController pushViewController:upvc animated:YES];
}
- (void) loadView
{
    srand(time(0));
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Avatar", @selector(addAvatar));
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
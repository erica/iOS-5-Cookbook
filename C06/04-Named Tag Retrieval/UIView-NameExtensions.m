/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "UIView-NameExtensions.h"

@interface ViewIndexer : NSObject {
	NSMutableDictionary *tagdict;
	NSInteger count;
}
@end

@implementation ViewIndexer

#pragma mark sharedInstance
static ViewIndexer *sharedInstance = nil;

+(ViewIndexer *) sharedInstance {
    if(!sharedInstance) sharedInstance = [[self alloc] init];
    return sharedInstance;
}

- (id) init
{
	if (!(self = [super init])) return self;
	tagdict = [NSMutableDictionary dictionary];
	count = 10000;
	return self;
}

#pragma mark registration
// Pull a new number and increase the count
- (NSInteger) pullNumber
{
	return count++;
}

// Check to see if name exists in dictionary
- (BOOL) nameExists: (NSString *) aName
{
	return [tagdict objectForKey:aName] != nil;
}

// Pull out first matching name for tag
- (NSString *) nameForTag: (NSInteger) aTag
{
	NSNumber *tag = [NSNumber numberWithInt:aTag];
	NSArray *names = [tagdict allKeysForObject:tag];
	if (!names) return nil;
	if ([names count] == 0) return nil;
	return [names objectAtIndex:0];
}

// Return the tag for a registered name. 0 if not found
- (NSInteger) tagForName: (NSString *)aName
{
	NSNumber *tag = [tagdict objectForKey:aName];
	if (!tag) return 0;
	return [tag intValue];
}

// Unregistering reverts tag to 0
- (BOOL) unregisterName: (NSString *) aName forView: (UIView *) aView
{
	NSNumber *tag = [tagdict objectForKey:aName];
	
	// tag not found
	if (!tag) return NO;
	
	// tag does not match registered name
	if (aView.tag != [tag intValue]) return NO;
	
	aView.tag = 0;
	[tagdict removeObjectForKey:aName];
	return YES;
}

// Register a new name. Names will not re-register (unregister first, please).
// If a view is already registered, it is unregistered and re-registered
- (NSInteger) registerName:(NSString *)aName forView: (UIView *) aView
{
	// You cannot re-register an existing name
	if ([[ViewIndexer sharedInstance] nameExists:aName]) return 0;
	
	// Check to see if the view is named already. If so, unregister.
	NSString *currentName = [self nameForTag:aView.tag];
	if (currentName) [self unregisterName:currentName forView:aView];
	
	// Register the existing tag or pull a new tag if aView.tag is 0
	if (!aView.tag) aView.tag = [[ViewIndexer sharedInstance] pullNumber];
	[tagdict setObject:[NSNumber numberWithInt:aView.tag] forKey:aName];
	return aView.tag;
}
@end

#pragma mark - Associations
enum {
    OBJC_ASSOCIATION_ASSIGN = 0,
    OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1,
    OBJC_ASSOCIATION_COPY_NONATOMIC = 3,
    OBJC_ASSOCIATION_RETAIN = 01401,
    OBJC_ASSOCIATION_COPY = 01403
};


typedef uintptr_t objc_AssociationPolicy;
id objc_getAssociatedObject(id object, void *key);
void objc_setAssociatedObject(id object, void *key, id value, objc_AssociationPolicy policy);
void objc_removeAssociatedObjects(id object);


static const char *NametagKey = "Nametag Key";

@implementation UIView (NameExtensions)
#pragma mark Associations
- (id) nametag 
{
    return objc_getAssociatedObject(self, (void *) NametagKey);
}

- (void)setNametag:(NSString *) theNametag 
{
    objc_setAssociatedObject(self, (void *) NametagKey, theNametag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *) viewWithNametag: (NSString *) aName
{
    if (!aName) return nil;
    
    // Is this the right view?
    if ([self.nametag isEqualToString:aName])
        return self;
    
    // Recurse depth first on subviews
    for (UIView *subview in self.subviews) 
    {
        UIView *resultView = [subview viewNamed:aName];
        if (resultView) return resultView;
    }
    
    // Not found
    return nil;
}


#pragma mark Registration
- (NSInteger) registerName: (NSString *) aName
{
	return [[ViewIndexer sharedInstance] registerName:aName forView:self];
}

- (BOOL) unregisterName: (NSString *) aName
{
	return [[ViewIndexer sharedInstance] unregisterName:aName forView:self];
}

#pragma mark Typed Name Retrieval
- (UIView *) viewNamed: (NSString *) aName
{
    if (!aName) return nil;
    
    // Uncomment for Registered Names
    /*
	NSInteger tag = [[ViewIndexer sharedInstance] tagForName:aName];
	return [self viewWithTag:tag];
     */
    
    // Uncomment for Associated Names
    return [self viewWithNametag:aName];
}

- (UIAlertView *) alertViewNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIAlertView class]])
        return (UIAlertView *)aView;
    return nil;
}

- (UIActionSheet *) actionSheetNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIActionSheet class]])
        return (UIActionSheet *)aView;
    return nil;
}

- (UITableView *) tableViewNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UITableView class]])
        return (UITableView *)aView;
    return nil;
}

- (UITableViewCell *) tableViewCellNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UITableViewCell class]])
        return (UITableViewCell *)aView;
    return nil;
}

- (UIImageView *) imageViewNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIImageView class]])
        return (UIImageView *)aView;
    return nil;
}

- (UIWebView *) webViewNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIWebView class]])
        return (UIWebView *)aView;
    return nil;
}

- (UITextView *) textViewNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UITextView class]])
        return (UITextView *)aView;
    return nil;
}

- (UIScrollView *) scrollViewNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIScrollView class]])
        return (UIScrollView *)aView;
    return nil;
}

- (UIPickerView *) pickerViewNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIPickerView class]])
        return (UIPickerView *)aView;
    return nil;
}

- (UIDatePicker *) datePickerNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIDatePicker class]])
        return (UIDatePicker *)aView;
    return nil;
}

- (UISegmentedControl *) segmentedControlNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UISegmentedControl class]])
        return (UISegmentedControl *)aView;
    return nil;
}

- (UILabel *) labelNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UILabel class]])
        return (UILabel *)aView;
    return nil;
}

- (UIButton *) buttonNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIButton class]])
        return (UIButton *)aView;
    return nil;
}

- (UITextField *) textFieldNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UITextField class]])
        return (UITextField *)aView;
    return nil;
}

- (UISwitch *) switchNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UISwitch class]])
        return (UISwitch *)aView;
    return nil;
}

- (UISlider *) sliderNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UISlider class]])
        return (UISlider *)aView;
    return nil;
}

- (UIProgressView *) progressViewNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIProgressView class]])
        return (UIProgressView *)aView;
    return nil;
}

- (UIActivityIndicatorView *) activityIndicatorViewNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIAlertView class]])
        return (UIActivityIndicatorView *)aView;
    return nil;
}

- (UIPageControl *) pageControlNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIPageControl class]])
        return (UIPageControl *)aView;
    return nil;
}

- (UIWindow *) windowNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIWindow class]])
        return (UIWindow *)aView;
    return nil;
}

- (UISearchBar *) searchBarNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UISearchBar class]])
        return (UISearchBar *)aView;
    return nil;
}

- (UINavigationBar *) navigationBarNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UINavigationBar class]])
        return (UINavigationBar *)aView;
    return nil;
}

- (UIToolbar *) toolbarNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIToolbar class]])
        return (UIToolbar *)aView;
    return nil;
}

- (UITabBar *) tabBarNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UITabBar class]])
        return (UITabBar *)aView;
    return nil;
}

- (UIStepper *) stepperNamed: (NSString *) aName
{
    UIView *aView = [self viewNamed:aName];
    if (aView && [aView isKindOfClass:[UIStepper class]])
        return (UIStepper *)aView;
    return nil;
}
@end
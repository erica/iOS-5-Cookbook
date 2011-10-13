/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

@interface UIView (NameExtensions)

// Associated Object
@property (nonatomic, strong) NSString *nametag;
- (UIView *) viewWithNametag: (NSString *) aName;

// Regular Dictionary
- (NSInteger) registerName: (NSString *) aName;
- (BOOL) unregisterName: (NSString *) aName;

// Typed Access
- (UIView *) viewNamed: (NSString *) aName;
- (UIAlertView *) alertViewNamed: (NSString *) aName;
- (UIActionSheet *) actionSheetNamed: (NSString *) aName;
- (UITableView *) tableViewNamed: (NSString *) aName;
- (UITableViewCell *) tableViewCellNamed: (NSString *) aName;
- (UIImageView *) imageViewNamed: (NSString *) aName;
- (UIWebView *) webViewNamed: (NSString *) aName;
- (UITextView *) textViewNamed: (NSString *) aName;
- (UIScrollView *) scrollViewNamed: (NSString *) aName;
- (UIPickerView *) pickerViewNamed: (NSString *) aName;
- (UIDatePicker *) datePickerNamed: (NSString *) aName;
- (UISegmentedControl *) segmentedControlNamed: (NSString *) aName;
- (UILabel *) labelNamed: (NSString *) aName;
- (UIButton *) buttonNamed: (NSString *) aName;
- (UITextField *) textFieldNamed: (NSString *) aName;
- (UISwitch *) switchNamed: (NSString *) aName;
- (UISlider *) sliderNamed: (NSString *) aName;
- (UIProgressView *) progressViewNamed: (NSString *) aName;
- (UIActivityIndicatorView *) activityIndicatorViewNamed: (NSString *) aName;
- (UIPageControl *) pageControlNamed: (NSString *) aName;
- (UIWindow *) windowNamed: (NSString *) aName;
- (UISearchBar *) searchBarNamed: (NSString *) aName;
- (UINavigationBar *) navigationBarNamed: (NSString *) aName;
- (UIToolbar *) toolbarNamed: (NSString *) aName;
- (UITabBar *) tabBarNamed: (NSString *) aName;
- (UIStepper *) stepperNamed: (NSString *) aName;
@end


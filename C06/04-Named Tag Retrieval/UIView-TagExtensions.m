/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


#import "UIView-TagExtensions.h"

@implementation UIView (TagExtensions)
- (UIAlertView *) alertViewWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UIAlertView class]])
        return (UIAlertView *) aView;
    return nil;
}

- (UIActionSheet *) actionSheetWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UIActionSheet class]])
        return (UIActionSheet *) aView;
    return nil;
}

- (UITableView *) tableViewWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UITableView class]])
        return (UITableView *) aView;
    return nil;
}

- (UITableViewCell *) tableViewCellWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UITableViewCell class]])
        return (UITableViewCell *) aView;
    return nil;
}

- (UIImageView *) imageViewWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UIImageView class]])
        return (UIImageView *) aView;
    return nil;
}

- (UIWebView *) webViewWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UIWebView class]])
        return (UIWebView *) aView;
    return nil;
}

- (UITextView *) textViewWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UITextView class]])
        return (UITextView *) aView;
    return nil;
}

- (UIScrollView *) scrollViewWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UIScrollView class]])
        return (UIScrollView *) aView;
    return nil;
}

- (UIPickerView *) pickerViewWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UIPickerView class]])
        return (UIPickerView *) aView;
    return nil;
}

- (UIDatePicker *) datePickerWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UIDatePicker class]])
        return (UIDatePicker *) aView;
    return nil;
}

- (UISegmentedControl *) segmentedControlWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UISegmentedControl class]])
        return (UISegmentedControl *) aView;
    return nil;
}

- (UILabel *) labelWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UILabel class]])
        return (UILabel *) aView;
    return nil;
}

- (UIButton *) buttonWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UIButton class]])
        return (UIButton *) aView;
    return nil;
}

- (UITextField *) textFieldWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UITextField class]])
        return (UITextField *) aView;
    return nil;
}

- (UIStepper *) stepperWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UIStepper class]])
        return (UIStepper *) aView;
    return nil;
}

- (UISwitch *) switchWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UISwitch class]])
        return (UISwitch *) aView;
    return nil;
}

- (UISlider *) sliderWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UISlider class]])
        return (UISlider *) aView;
    return nil;
}

- (UIProgressView *) progressViewWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UIProgressView class]])
        return (UIProgressView *) aView;
    return nil;
}

- (UIActivityIndicatorView *) activityIndicatorViewWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UIActivityIndicatorView class]])
        return (UIActivityIndicatorView *) aView;
    return nil;
}

- (UIPageControl *) pageControlWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UIPageControl class]])
        return (UIPageControl *) aView;
    return nil;
}

- (UIWindow *) windowWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UIWindow class]])
        return (UIWindow *) aView;
    return nil;
}

- (UISearchBar *) searchBarWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UISearchBar class]])
        return (UISearchBar *) aView;
    return nil;
}

- (UINavigationBar *) navigationBarWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UINavigationBar class]])
        return (UINavigationBar *) aView;
    return nil;
}

- (UIToolbar *) toolbarWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UIToolbar class]])
        return (UIToolbar *) aView;
    return nil;
}

- (UITabBar *) tabBarWithTag: (NSInteger) aTag
{
    UIView *aView = [self viewWithTag:aTag];
    if (aView && [aView isKindOfClass:[UITabBar class]])
        return (UITabBar *) aView;
    return nil;
}
@end
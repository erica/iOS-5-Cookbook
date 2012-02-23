/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

@interface ModalSheetDelegate : NSObject <UIActionSheetDelegate>
{
    UIActionSheet *actionSheet;
    int index;
}
+ (id) delegateWithSheet: (UIActionSheet *) aSheet;
- (int) showFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated;
- (int) showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated;
- (int) showFromTabBar:(UITabBar *)view;
- (int) showFromToolbar:(UIToolbar *)view;
- (int) showInView:(UIView *)view;
@end

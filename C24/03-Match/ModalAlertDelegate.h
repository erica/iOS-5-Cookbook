/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

@interface ModalAlertDelegate : NSObject <UIAlertViewDelegate>
{
    UIAlertView *alertView;
    int index;
}
+ (id) delegateWithAlert: (UIAlertView *) anAlert;
- (int) show;
@end

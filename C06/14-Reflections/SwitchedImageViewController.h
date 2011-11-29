/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

@interface SwitchedImageViewController : UIViewController 
{
    IBOutlet UISwitch *s;
    IBOutlet UIImageView *iv;
}
- (IBAction) switchChanged: (UISwitch *) aSwitch;
@end

/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "SwitchedImageViewController.h"
@implementation SwitchedImageViewController

- (void) switchChanged: (UISwitch *) aSwitch
{
    iv.alpha = aSwitch.isOn ? 1.0f : 0.5f;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    iv.alpha = 0.5f;
}
@end

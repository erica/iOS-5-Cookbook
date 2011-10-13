/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ReflectingView : UIView 
{
    CAGradientLayer *gradient;
}
- (void) setupReflection;
@property (nonatomic, assign) BOOL usesGradientOverlay;
@end

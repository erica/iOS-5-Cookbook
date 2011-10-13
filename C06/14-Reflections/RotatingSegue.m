/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <QuartzCore/QuartzCore.h>

#import "RotatingSegue.h"
#import "SwitchedImageViewController.h"

#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)

@implementation RotatingSegue
@synthesize goesForward;
@synthesize delegate;

- (void)perform
{
    UIViewController *source = (UIViewController *) super.sourceViewController;
    UIViewController *dest = (UIViewController *) super.destinationViewController;

    // Move out by half of the parent's width
    UIView *backsplash = source.view.superview;
    float endLoc = (goesForward ? 1.0f : -1.0f) * backsplash.frame.size.width;

    // Move into the backsplash
    dest.view.frame = backsplash.bounds;
    dest.view.alpha = 0.0f;
    
    // Reverse the transform for the destination's start
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-endLoc, 0.0f);
    transform = CGAffineTransformScale(transform, 0.1f, 0.1f);
    dest.view.transform = transform;
    
    [UIView animateWithDuration:0.6f animations:^(void)
     {
         // Move the destination view into place
         [backsplash addSubview:dest.view];
         dest.view.alpha = 1.0f;
         dest.view.transform = CGAffineTransformIdentity;
         
         // Spin out the source view and hide it
         CGAffineTransform transform = CGAffineTransformMakeTranslation(endLoc, 0.0f);
         transform = CGAffineTransformScale(transform, 0.1f, 0.1f);
         source.view.alpha = 0.0f;
         source.view.transform = transform;

     } completion: ^(BOOL done)
     {
         // Remove and restore the source view
         [source.view removeFromSuperview];
         source.view.alpha = 1.0f;
         source.view.transform = CGAffineTransformIdentity;

         // Update the delegate
         if (delegate)
             SAFE_PERFORM_WITH_ARG(delegate, @selector(segueDidComplete), nil);
     }];
}
@end
/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "ReflectingView.h"

@implementation ReflectingView
@synthesize usesGradientOverlay;

// Always use a replicator as the base layer
+ (Class) layerClass
{
    return [CAReplicatorLayer class];
}

// Clean up any existing gradient from parent
- (void) dealloc
{
    [gradient removeFromSuperlayer];
}

- (void) setupGradient
{
    // Add a new gradient layer to the parent
    UIView *parent = self.superview;
    if (!gradient)
    {
        gradient = [CAGradientLayer layer];
        CGColorRef c1 = [[UIColor blackColor] colorWithAlphaComponent:0.5f].CGColor;
        CGColorRef c2 = [[UIColor blackColor] colorWithAlphaComponent:0.9f].CGColor;
        [gradient setColors:[NSArray arrayWithObjects:
                             (__bridge id)c1, (__bridge id)c2, nil]];
        [parent.layer addSublayer:gradient];
    }
    
    // Place the gradient just below the view using the reflection's geometry
    float desiredGap = 10.0f;
    CGFloat shrinkFactor = 0.25f;
    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width;
    CGFloat y = self.frame.origin.y;
    
    [gradient setAnchorPoint:CGPointMake(0.0f,0.0f)];
    [gradient setFrame:CGRectMake(0.0f, y + height + desiredGap, width, height * shrinkFactor)];
    [gradient removeAllAnimations];
}

- (void) setupReflection
{
    CGFloat height = self.bounds.size.height;
    CGFloat shrinkFactor = 0.25f;
    
    CATransform3D t = CATransform3DMakeScale(1.0, -shrinkFactor, 1.0);
    
    // scaling centers the shadow in the view. translate in shrunken terms
    float offsetFromBottom = height * ((1.0f - shrinkFactor) / 2.0f);
    float inverse = 1.0 / shrinkFactor;
    float desiredGap = 10.0f;
    t = CATransform3DTranslate(t, 0.0, -offsetFromBottom * inverse - height - inverse * desiredGap, 0.0f);
    
    CAReplicatorLayer *replicatorLayer = (CAReplicatorLayer*)self.layer;
    replicatorLayer.instanceTransform = t;
    replicatorLayer.instanceCount = 2;
    
    // Gradient use must be explicitely set
    if (usesGradientOverlay)
        [self setupGradient];
    else
    {
        // Darken the reflection when not using a gradient
        replicatorLayer.instanceRedOffset = -0.75;
        replicatorLayer.instanceGreenOffset = -0.75;
        replicatorLayer.instanceBlueOffset = -0.75;
    }
}
@end
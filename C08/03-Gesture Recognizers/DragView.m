/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "DragView.h"

@implementation DragView
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Promote the touched view
	[self.superview bringSubviewToFront:self];

	// initialize translation offsets
	tx = self.transform.tx;
	ty = self.transform.ty;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	if (touch.tapCount == 3)
	{
		// Reset geometry upon double-tap
		self.transform = CGAffineTransformIdentity;
		tx = 0.0f; ty = 0.0f; scale = 1.0f;	theta = 0.0f;
	}
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}

- (void) updateTransformWithOffset: (CGPoint) translation
{
	// Create a blended transform representing translation, rotation, and scaling
	self.transform = CGAffineTransformMakeTranslation(translation.x + tx, translation.y + ty);
	self.transform = CGAffineTransformRotate(self.transform, theta);	
	self.transform = CGAffineTransformScale(self.transform, scale, scale);
    
    NSLog(@"Xscale: %f YScale: %f Rotation: %f", self.xscale, self.yscale, self.rotation * (180 / M_PI));
}

- (void) handlePan: (UIPanGestureRecognizer *) uigr
{
	CGPoint translation = [uigr translationInView:self.superview];
	[self updateTransformWithOffset:translation];
}

- (void) handleRotation: (UIRotationGestureRecognizer *) uigr
{
	theta = uigr.rotation;
	[self updateTransformWithOffset:CGPointZero];
}

- (void) handlePinch: (UIPinchGestureRecognizer *) uigr
{
	scale = uigr.scale;
	[self updateTransformWithOffset:CGPointZero];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}


- (id) initWithImage:(UIImage *)image
{
	// Initialize and set as touchable
	if (!(self = [super initWithImage:image])) return self;
	
	self.userInteractionEnabled = YES;
	
	// Reset geometry to identities
	self.transform = CGAffineTransformIdentity;
	tx = 0.0f; ty = 0.0f; scale = 1.0f;	theta = 0.0f;

	// Add gesture recognizer suite
	UIRotationGestureRecognizer *rot = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
	UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	self.gestureRecognizers = [NSArray arrayWithObjects: rot, pinch, pan, nil];
	for (UIGestureRecognizer *recognizer in self.gestureRecognizers) recognizer.delegate = self;
	
	return self;
}
@end

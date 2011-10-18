//
//  StarSlider.m
//  HelloWorld
//
//  Created by Erica Sadun on 2/25/10.
//  Copyright 2010 Up To No Good, Inc. All rights reserved.
//

#import "StarSlider.h"

#define WIDTH 24.0f
#define OFF_ART	[UIImage imageNamed:@"Star-White-Half.png"]
#define ON_ART	[UIImage imageNamed:@"Star-White.png"]

@implementation StarSlider
@synthesize value;

- (id) initWithFrame: (CGRect) aFrame
{
	if (self = [super initWithFrame:aFrame])
	{
		float minimumWidth = WIDTH * 8.0f; // 5 stars, spaced between + 1/2 size on each end
		float minimumHeight = 34.0f;
		
		// This control uses a minimum 260x34 sized frame
		self.frame = CGRectMake(0.0f, 0.0f, MAX(minimumWidth, aFrame.size.width), MAX(minimumHeight, aFrame.size.height));
		
		// Add stars -- initially assuming fixed width
		float offsetCenter = WIDTH;
		for (int i = 1; i <= 5; i++)
		{
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, WIDTH, WIDTH)];
			imageView.image = OFF_ART;
			imageView.center = CGPointMake(offsetCenter, self.frame.size.height / 2.0f);
			offsetCenter += WIDTH * 1.5f;
			[self addSubview:imageView];
		}
	}
	
	self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25f];

	return self;
}

- (id) init
{
	return [self initWithFrame:CGRectZero];
}

+ (id) control
{
	return [[self alloc] init];
}

- (void) updateValueAtPoint: (CGPoint) p
{
	int newValue = 0;
	UIImageView *changedView = nil;
	
	for (UIImageView *eachItem in [self subviews])
		if (p.x < eachItem.frame.origin.x)
		{
			eachItem.image = OFF_ART;
		}
		else 
		{
			changedView = eachItem;
			eachItem.image = ON_ART;
			newValue++;
		}
	
	if (self.value != newValue)
	{
		self.value = newValue;
		[self sendActionsForControlEvents:UIControlEventValueChanged];
		
		// Animate the changed view
		[UIView animateWithDuration:0.15f 
						 animations:^{changedView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);}
						 completion:^(BOOL done){[UIView animateWithDuration:0.1f animations:^{changedView.transform = CGAffineTransformIdentity;}];}];
	}	
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	// Establish touch down event
	CGPoint touchPoint = [touch locationInView:self];
	[self sendActionsForControlEvents:UIControlEventTouchDown];
	
	// Calcluate value
	[self updateValueAtPoint:touchPoint];
	return YES;
}
	 
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	// Test if drag is currently inside or outside
	CGPoint touchPoint = [touch locationInView:self];
	if (CGRectContainsPoint(self.frame, touchPoint))
        [self sendActionsForControlEvents:UIControlEventTouchDragInside];
    else 
        [self sendActionsForControlEvents:UIControlEventTouchDragOutside];

	// Calculate value
	[self updateValueAtPoint:[touch locationInView:self]];
	return YES;
}

- (void) endTrackingWithTouch: (UITouch *)touch withEvent: (UIEvent *)event
{
    // Test if touch ended inside or outside
    CGPoint touchPoint = [touch locationInView:self];
    if (CGRectContainsPoint(self.bounds, touchPoint))
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    else 
        [self sendActionsForControlEvents:UIControlEventTouchUpOutside];
}

	 
- (void)cancelTrackingWithEvent: (UIEvent *) event
{
	[self sendActionsForControlEvents:UIControlEventTouchCancel];
}
@end

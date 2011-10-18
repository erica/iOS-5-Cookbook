//
//  PullView.m
//  HelloWorld
//
//  Created by Erica Sadun on 7/21/11.
//  Copyright 2011 Up To No Good, Inc. All rights reserved.
//

#import "PullView.h"


#pragma mark Pull-out-an-Image View for use in scroll view

#define DX(p1, p2)	(p2.x - p1.x)
#define DY(p1, p2)	(p2.y - p1.y)

#define SWIPE_DRAG_MIN 16
#define DRAGLIMIT_MAX 12 

typedef enum {
	TouchUnknown,
	TouchSwipeLeft,
	TouchSwipeRight,
	TouchSwipeUp,
	TouchSwipeDown,
} SwipeTypes;

@implementation PullView
- (id) initWithImage: (UIImage *) anImage
{
	if (self = [super initWithImage:anImage])
	{
		self.userInteractionEnabled = YES;
		UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        pan.delegate = self;
		self.gestureRecognizers = [NSArray arrayWithObjects: pan, nil];
	}
	return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void) handlePan: (UIPanGestureRecognizer *) uigr
{
	// Only deal with scroll view superviews
	if (![self.superview isKindOfClass:[UIScrollView class]]) return;
    
	// Extract super views
	UIView *supersuper = self.superview.superview;
	UIScrollView *scrollView = (UIScrollView *) self.superview;
	
	// Calculate location of touch
	CGPoint touchLocation = [uigr locationInView:supersuper];
	
	if (uigr.state == UIGestureRecognizerStateBegan) 
	{
		// Initialize recognizer
		gestureWasHandled = NO;
		pointCount = 1;
		startPoint = touchLocation;
	}
	
    if (uigr.state == UIGestureRecognizerStateChanged) 
    {
        pointCount++;
        
        // Calculate whether a swipe has occured
        float dx = DX(touchLocation, startPoint);
        float dy = DY(touchLocation, startPoint);
        
        // Detect known swipe-types
        BOOL finished = YES;
        if ((dx > SWIPE_DRAG_MIN) && (ABS(dy) < DRAGLIMIT_MAX)) // hswipe left
            touchtype = TouchSwipeLeft;
        else if ((-dx > SWIPE_DRAG_MIN) && (ABS(dy) < DRAGLIMIT_MAX)) // hswipe right
            touchtype = TouchSwipeRight;
        else if ((dy > SWIPE_DRAG_MIN) && (ABS(dx) < DRAGLIMIT_MAX)) // vswipe up
            touchtype = TouchSwipeUp;
        else if ((-dy > SWIPE_DRAG_MIN) && (ABS(dx) < DRAGLIMIT_MAX)) // vswipe down
            touchtype = TouchSwipeDown;
        else
            finished = NO;
        
        // If unhandled and a downward swipe, produce a new draggable view
        if (!gestureWasHandled && finished && (touchtype == TouchSwipeDown))
        {
            dv = [[DragView alloc] initWithImage:self.image];
            dv.center = touchLocation;
            dv.backgroundColor = [UIColor clearColor];
            [supersuper addSubview:dv];			
            scrollView.scrollEnabled = NO;
            gestureWasHandled = YES;
        }
        else if (gestureWasHandled)
        {
            // allow continued dragging after detection
            dv.center = touchLocation;
        }
    }
    
    if (uigr.state == UIGestureRecognizerStateEnded)
    {
        // ensure that the scroll view returns to scrollable
        if (gestureWasHandled)
            scrollView.scrollEnabled = YES;
    }
}
@end 




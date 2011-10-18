//
//  PullView.h
//  HelloWorld
//
//  Created by Erica Sadun on 7/21/11.
//  Copyright 2011 Up To No Good, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DragView.h"

@interface PullView : UIImageView <UIGestureRecognizerDelegate>
{
	DragView *dv;
	BOOL gestureWasHandled;
	int pointCount;
	CGPoint startPoint;
	NSUInteger touchtype;
}
@end
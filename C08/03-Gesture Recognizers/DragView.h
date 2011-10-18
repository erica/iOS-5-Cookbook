/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


#import <UIKit/UIKit.h>


@interface DragView : UIImageView <UIGestureRecognizerDelegate>
{
	CGFloat tx; // x translation
	CGFloat ty; // y translation
	CGFloat scale; // zoom scale
	CGFloat theta; // rotation angle
}
@end

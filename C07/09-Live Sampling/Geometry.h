/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


#import <Foundation/Foundation.h>

#define RECTSTRING(_aRect_)		NSStringFromCGRect(_aRect_)
#define POINTSTRING(_aPoint_)	NSStringFromCGPoint(_aPoint_)
#define SIZESTRING(_aSize_)		NSStringFromCGSize(_aSize_)

// Centering
CGPoint CGRectGetCenter(CGRect rect);
CGRect	CGRectAroundCenter(CGPoint center, float dx, float dy);
CGRect	CGRectCenteredInRect(CGRect rect, CGRect mainRect);

// Offset, Scaling
CGPoint CGPointOffset(CGPoint aPoint, CGFloat dx, CGFloat dy);
CGPoint CGPointScale(CGPoint aPoint, CGFloat wScale, CGFloat hScale);
CGSize  CGSizeScale(CGSize aSize, CGFloat wScale, CGFloat hScale);
CGRect  CGRectScaleRect(CGRect rect, CGFloat wScale, CGFloat hScale);
CGRect  CGRectScaleOrigin(CGRect rect, CGFloat wScale, CGFloat hScale);
CGRect  CGRectScaleSize(CGRect rect, CGFloat wScale, CGFloat hScale);

// Mirror
CGRect  CGRectFlipHorizontal(CGRect rect, CGRect outerRect);
CGRect  CGRectFlipVertical(CGRect rect, CGRect outerRect);
CGPoint CGPointFlipHorizontal(CGPoint point, CGRect outerRect);
CGPoint CGPointFlipVertical(CGPoint point, CGRect outerRect);

// Flipping coordinates
CGRect  CGRectFlipFlop(CGRect rect);
CGRect  CGRectFlipOrigin(CGRect rect);
CGRect  CGRectFlipSize(CGRect rect);
CGSize  CGSizeFlip(CGSize size);
CGPoint CGPointFlip(CGPoint point);

// Aspect and fitting
CGSize  CGSizeFitInSize(CGSize sourceSize, CGSize destSize);
CGRect  CGRectFitSizeInRect(CGSize sourceSize, CGRect destRect);
CGFloat CGAspectScaleFit(CGSize sourceSize, CGRect destRect);
CGFloat CGAspectScaleFill(CGSize sourceSize, CGRect destRect);
CGRect  CGRectAspectFitRect(CGSize sourceSize, CGRect destRect);
CGRect  CGRectAspectFillRect(CGSize sourceSize, CGRect destRect);
CGSize  CGRectGetScale(CGRect sourceRect, CGRect destRect);
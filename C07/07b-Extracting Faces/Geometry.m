/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "Geometry.h"

CGPoint CGRectGetCenter(CGRect rect)
{
	return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

CGRect CGRectAroundCenter(CGPoint center, float dx, float dy)
{
	return CGRectMake(center.x - dx, center.y - dy, dx * 2, dy * 2);
}

CGRect CGRectCenteredInRect(CGRect rect, CGRect mainRect)
{
    CGFloat dx = CGRectGetMidX(mainRect)-CGRectGetMidX(rect);
    CGFloat dy = CGRectGetMidY(mainRect)-CGRectGetMidY(rect);
	return CGRectOffset(rect, dx, dy);
}

CGPoint CGPointOffset(CGPoint aPoint, CGFloat dx, CGFloat dy)
{
    return CGPointMake(aPoint.x + dx, aPoint.y + dy);
}

CGSize CGSizeScale(CGSize aSize, CGFloat wScale, CGFloat hScale)
{
    return CGSizeMake(aSize.width * wScale, aSize.height * hScale);
}

CGPoint CGPointScale(CGPoint aPoint, CGFloat wScale, CGFloat hScale)
{
    return CGPointMake(aPoint.x * wScale, aPoint.y * hScale);
}

CGRect CGRectScaleRect(CGRect rect, CGFloat wScale, CGFloat hScale)
{
    return CGRectMake(rect.origin.x * wScale, rect.origin.y * hScale, rect.size.width * wScale, rect.size.height * hScale);
}

CGRect CGRectScaleSize(CGRect rect, CGFloat wScale, CGFloat hScale)
{
    return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width * wScale, rect.size.height * hScale);
}

CGRect  CGRectScaleOrigin(CGRect rect, CGFloat wScale, CGFloat hScale)
{
    return CGRectMake(rect.origin.x * wScale, rect.origin.y * hScale, rect.size.width, rect.size.height);
}

CGRect CGRectFlipHorizontal(CGRect innerRect, CGRect outerRect)
{
    CGRect rect = innerRect;
    rect.origin.x = outerRect.origin.x + outerRect.size.width - (rect.origin.x + rect.size.width);
    return rect;
}

CGPoint CGPointFlipHorizontal(CGPoint point, CGRect outerRect)
{
    CGPoint newPoint = point;
    newPoint.x = outerRect.origin.x + outerRect.size.width - point.x;
    return newPoint;

}

CGPoint CGPointFlipVertical(CGPoint point, CGRect outerRect)
{
    CGPoint newPoint = point;
    newPoint.y = outerRect.origin.y + outerRect.size.height - point.y;
    return newPoint;
}


CGRect CGRectFlipVertical(CGRect innerRect, CGRect outerRect)
{
    CGRect rect = innerRect;
    rect.origin.y = outerRect.origin.y + outerRect.size.height - (rect.origin.y + rect.size.height);
    return rect;
}

CGSize CGSizeFlip(CGSize size)
{
    return CGSizeMake(size.height, size.width);
}

CGPoint CGPointFlip(CGPoint point)
{
    return CGPointMake(point.y, point.x);
}

CGRect CGRectFlipFlop(CGRect rect)
{
    return CGRectMake(rect.origin.y, rect.origin.x, rect.size.height, rect.size.width);
}

// Does not affect point of origin
CGRect CGRectFlipSize(CGRect rect)
{
    return CGRectMake(rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);
}

// Does not affect size
CGRect  CGRectFlipOrigin(CGRect rect)
{
    return CGRectMake(rect.origin.y, rect.origin.x, rect.size.width, rect.size.height);
}

CGSize CGSizeFitInSize(CGSize sourceSize, CGSize destSize)
{
	CGFloat destScale;
	CGSize newSize = sourceSize;
	
	if (newSize.height && (newSize.height > destSize.height))
	{
		destScale = destSize.height / newSize.height;
		newSize.width *= destScale;
		newSize.height *= destScale;
	}
	
	if (newSize.width && (newSize.width >= destSize.width))
	{
		destScale = destSize.width / newSize.width;
		newSize.width *= destScale;
		newSize.height *= destScale;
	}
	
	return newSize;
}

// Only scales down, not up, and centers result
CGRect CGRectFitSizeInRect(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
	CGSize targetSize = CGSizeFitInSize(sourceSize, destSize);
	float dWidth = destSize.width - targetSize.width;
	float dHeight = destSize.height - targetSize.height;
	
	return CGRectMake(dWidth / 2.0f, dHeight / 2.0f, targetSize.width, targetSize.height);
}


CGFloat CGAspectScaleFit(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
    CGFloat scaleW = destSize.width / sourceSize.width;
	CGFloat scaleH = destSize.height / sourceSize.height; 
    return MIN(scaleW, scaleH);	
}

CGRect CGRectAspectFitRect(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
	CGFloat destScale = CGAspectScaleFit(sourceSize, destRect);	
	
	CGFloat newWidth = sourceSize.width * destScale;
	CGFloat newHeight = sourceSize.height * destScale;
	
	float dWidth = ((destSize.width - newWidth) / 2.0f);
	float dHeight = ((destSize.height - newHeight) / 2.0f);
	
	CGRect rect = CGRectMake(dWidth, dHeight, newWidth, newHeight);
	return rect;
}

CGFloat CGAspectScaleFill(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
    CGFloat scaleW = destSize.width / sourceSize.width;
	CGFloat scaleH = destSize.height / sourceSize.height; 
    return MAX(scaleW, scaleH);	
}

CGRect CGRectAspectFillRect(CGSize sourceSize, CGRect destRect)
{
    CGSize destSize = destRect.size;
	CGFloat destScale = CGAspectScaleFill(sourceSize, destRect);
	
	CGFloat newWidth = sourceSize.width * destScale;
	CGFloat newHeight = sourceSize.height * destScale;
	
	float dWidth = ((destSize.width - newWidth) / 2.0f);
	float dHeight = ((destSize.height - newHeight) / 2.0f);
	
	CGRect rect = CGRectMake(dWidth, dHeight, newWidth, newHeight);
	return rect;
}

CGSize CGRectGetScale(CGRect sourceRect, CGRect destRect)
{
    CGSize sourceSize = sourceRect.size;
    CGSize destSize = destRect.size;
    
    CGFloat scaleW = destSize.width / sourceSize.width;
	CGFloat scaleH = destSize.height / sourceSize.height; 
    
    return CGSizeMake(scaleW, scaleH);
}
//
//  UIColor-Random.m
//  HelloWorld
//
//  Created by Erica Sadun on 7/21/11.
//  Copyright 2011 Up To No Good, Inc. All rights reserved.
//

#import "UIColor-Random.h"
// Return a random block image
UIImage *randomBlockImage(CGFloat sideLength, CGFloat inset)
{
	UIGraphicsBeginImageContext(CGSizeMake(sideLength, sideLength));
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	// Draw in saturated background
	CGRect bounds = CGRectMake(0.0f, 0.0f, sideLength, sideLength);
	CGContextAddRect(context, bounds);
	[[UIColor whiteColor] set];
	CGContextFillPath(context);
	CGContextAddRect(context, bounds);
	[[[UIColor randomColor] colorWithAlphaComponent:0.5f] set];
	CGContextFillPath(context);
    
	// Draw in brighter foreground
	CGContextAddEllipseInRect(context, CGRectInset(bounds, inset, inset));
	[[UIColor randomColor] set];
	CGContextFillPath(context);
    
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}


@implementation UIColor(Random)
+(UIColor *)randomColor
{
    static BOOL seeded = NO;
    if (!seeded) {
        seeded = YES;
        srandom(time(NULL));
    }
	
    CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}
@end


//
//  UIColor-Random.m
//  CloudLearning
//
//  Created by Erica Sadun on 7/8/11.
//  Copyright 2011 Up To No Good, Inc. All rights reserved.
//

#import "UIColor-Random.h"

#pragma mark color
@implementation UIColor(Random)
+(UIColor *)randomColor
{
    static BOOL seeded = NO;
    if (!seeded) {seeded = YES; srandom(time(NULL));}
    CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

+(NSData *) randomSwatchData
{
    UIColor *aColor = [self randomColor];
    CGRect rect = (CGRect){.size = CGSizeMake(320.0f, 320.0f)};

    UIGraphicsBeginImageContext(rect.size);
    
    [[UIColor whiteColor] set];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
    
    [aColor set];
    [[UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 40.0f, 40.0f) cornerRadius:32.0f] fill];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return UIImageJPEGRepresentation(image, 0.75f);
}

@end


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
@end


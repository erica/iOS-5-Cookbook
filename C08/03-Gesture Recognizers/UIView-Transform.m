//
//  UIView-Transform.m
//  HelloWorld
//
//  Created by Erica Sadun on 5/1/12.
//  Copyright (c) 2012 Up To No Good, Inc. All rights reserved.
//

#import "UIView-Transform.h"

@implementation UIView (Transform)
- (CGFloat) rotation
{
    CGAffineTransform t = self.transform;
    return atan2f(t.b, t.a); 
}

- (CGFloat) xscale
{
    CGAffineTransform t = self.transform;
    return sqrt(t.a * t.a + t.c * t.c);
}

- (CGFloat) yscale
{
    CGAffineTransform t = self.transform;
    return sqrt(t.b * t.b + t.d * t.d);
}
@end

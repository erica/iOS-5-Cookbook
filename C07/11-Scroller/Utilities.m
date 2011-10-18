//
//  Utilities.m
//  CloudLearning
//
//  Created by Erica Sadun on 7/8/11.
//  Copyright 2011 Up To No Good, Inc. All rights reserved.
//

#import "Utilities.h"

#pragma mark geometry
CGPoint CGRectGetCenter(CGRect rect)
{
    CGPoint pt;
    pt.x = CGRectGetMidX(rect);
    pt.y = CGRectGetMidY(rect);
    return pt;
}


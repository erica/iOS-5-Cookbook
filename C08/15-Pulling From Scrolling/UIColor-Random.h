//
//  UIColor-Random.h
//  HelloWorld
//
//  Created by Erica Sadun on 7/21/11.
//  Copyright 2011 Up To No Good, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

UIImage *randomBlockImage(CGFloat sideLength, CGFloat inset);

@interface UIColor (Random)
+(UIColor *)randomColor;
@end

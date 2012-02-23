/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

@interface UIColor (Random)
+ (UIColor *) randomColor;
+ (UIImage *) randomSwatch: (CGFloat) sidelength;
+ (NSData *) randomSwatchData: (CGFloat) sidelength;
@end

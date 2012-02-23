/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "UIColor-Random.h"

#pragma mark color
@implementation UIColor(Random)
+ (UIColor *) randomColor
{
    static BOOL seeded = NO;
    if (!seeded) {seeded = YES; srandom(time(NULL));}
    CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

+ (UIImage *) randomSwatch: (CGFloat) sidelength
{
    CGRect rect = (CGRect){.size = CGSizeMake(sidelength, sidelength)};
    
    UIGraphicsBeginImageContext(rect.size);
        [[UIColor whiteColor] set];
        CGContextFillRect(UIGraphicsGetCurrentContext(), rect);

        [[self randomColor] set];
        [[UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 40.0f, 40.0f) cornerRadius:32.0f] fill];
    
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (NSData *) randomSwatchData: (CGFloat) sidelength
{
    return UIImageJPEGRepresentation([self randomSwatch:sidelength], 0.75f);
}

@end


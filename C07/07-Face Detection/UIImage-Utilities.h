/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


#import <UIKit/UIKit.h>

// There's a bug when creating CI Images from PNG vs JPEG
// This is a workaround
CIImage *ciImageFromPNG(NSString *pngFileName);

@interface UIImage (Utilities)

// Extract a subimage
- (UIImage *) subImageWithBounds:(CGRect) rect;

// This is a bug workaround for creating a UIImage from a CIImage
+ (UIImage *) imageWithCIImage: (CIImage *) aCIImage orientation: (UIImageOrientation) anOrientation;
@end

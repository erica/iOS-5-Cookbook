/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


#import <UIKit/UIKit.h>

// There's a bug when creating CI Images from PNG vs JPEG
// This is a workaround
CIImage *ciImageFromPNG(NSString *pngFileName);

// RGBA offsets
NSUInteger alphaOffset(NSUInteger x, NSUInteger y, NSUInteger w);
NSUInteger redOffset(NSUInteger x, NSUInteger y, NSUInteger w);
NSUInteger greenOffset(NSUInteger x, NSUInteger y, NSUInteger w);
NSUInteger blueOffset(NSUInteger x, NSUInteger y, NSUInteger w);

@interface UIImage (Utilities)
// Extract a subimage
- (UIImage *) subImageWithBounds:(CGRect) rect;

// Return a bitmap representation of the image
- (UInt8 *) createBitmap;

// Perform a basic Canny detection
- (UIImage *) convolveImageWithEdgeDetection;

// This is a bug workaround for creating a UIImage from a CIImage
+ (UIImage *) imageWithCIImage: (CIImage *) aCIImage orientation: (UIImageOrientation) anOrientation;

// Create an image from a bitmap
+ (UIImage *) imageWithBits: (UInt8 *) bits withSize: (CGSize) size;
@end

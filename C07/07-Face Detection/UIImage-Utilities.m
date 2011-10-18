/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


#import "UIImage-Utilities.h"

CIImage *ciImageFromPNG(NSString *pngFileName)
{
    UIImage *pngImage = [UIImage imageNamed:pngFileName];
    NSData *data = UIImageJPEGRepresentation(pngImage, 1.0f);
    UIImage *jpegImage = [[UIImage alloc] initWithData:data];    
    
    return [CIImage imageWithCGImage:jpegImage.CGImage];
}

@implementation UIImage (Utilities)
+ (UIImage *) imageWithCIImage: (CIImage *) aCIImage orientation: (UIImageOrientation) anOrientation
{
    if (!aCIImage) return nil;
    
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:aCIImage fromRect:aCIImage.extent];
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:1.0f orientation:anOrientation];
    CFRelease(cgImage);
    
    return image;
}

- (UIImage *) subImageWithBounds:(CGRect) rect
{
    UIGraphicsBeginImageContext(rect.size);
    
    CGRect destRect = CGRectMake(-rect.origin.x, -rect.origin.y, self.size.width, self.size.height);
    [self drawInRect:destRect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
@end

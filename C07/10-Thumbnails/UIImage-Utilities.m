/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


#import "UIImage-Utilities.h"
#import "Geometry.h"

NSUInteger alphaOffset(NSUInteger x, NSUInteger y, NSUInteger w)
{return y * w * 4 + x * 4 + 0;}
NSUInteger redOffset(NSUInteger x, NSUInteger y, NSUInteger w)
{return y * w * 4 + x * 4 + 1;}
NSUInteger greenOffset(NSUInteger x, NSUInteger y, NSUInteger w)
{return y * w * 4 + x * 4 + 2;}
NSUInteger blueOffset(NSUInteger x, NSUInteger y, NSUInteger w)
{return y * w * 4 + x * 4 + 3;}

CIImage *ciImageFromPNG(NSString *pngFileName)
{
    UIImage *pngImage = [UIImage imageNamed:pngFileName];
    NSData *data = UIImageJPEGRepresentation(pngImage, 1.0f);
    UIImage *jpegImage = [[UIImage alloc] initWithData:data];    
    
    return [CIImage imageWithCGImage:jpegImage.CGImage];
}

UIImage *imageFromView(UIView *theView)
{
	UIGraphicsBeginImageContext(theView.frame.size);
	[theView.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

UIImage *screenShot()
{
	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	return imageFromView(window);
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

+ (UIImage *) imageWithBits: (UInt8 *) bits withSize: (CGSize) size
{
	// Create a color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
		free(bits);
        return nil;
    }
	
	// Create the bitmap context
    CGContextRef context = CGBitmapContextCreate (bits, size.width, size.height, 8, size.width * 4, colorSpace, kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        fprintf (stderr, "Error: Context not created!");
        free (bits);
		CGColorSpaceRelease(colorSpace );
		return nil;
    }
	
	// Create the image ref
    CGColorSpaceRelease(colorSpace );
	CGImageRef imageRef = CGBitmapContextCreateImage(context);
	free(CGBitmapContextGetData(context)); // This does the free
	CGContextRelease(context);
	
	// Return image using image ref
	UIImage *newImage = [UIImage imageWithCGImage:imageRef];
	CFRelease(imageRef);

	return newImage;
}

// Proportionately resize, completely fit in view, no cropping
- (UIImage *) fitInSize: (CGSize) viewsize
{
    // calculate the fitted size
    CGSize size = CGSizeFitInSize(self.size, viewsize);
    
    UIGraphicsBeginImageContext(viewsize);
    
    // Calculate any matting needed for image spacing
    float dwidth = (viewsize.width - size.width) / 2.0f;
    float dheight = (viewsize.height - size.height) / 2.0f;
    
    CGRect rect = CGRectMake(dwidth, dheight, size.width, size.height);
    [self drawInRect:rect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

// No resize, may crop
- (UIImage *) centerInSize: (CGSize) viewsize
{
    CGSize size = self.size;
    UIGraphicsBeginImageContext(viewsize);
    
    // Calculate the offset to ensure that the image center is set
    // to the view center
    float dwidth = (viewsize.width - size.width) / 2.0f;
    float dheight = (viewsize.height - size.height) / 2.0f;
    
    CGRect rect = CGRectMake(dwidth, dheight, size.width, size.height);
    [self drawInRect:rect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

// Fill every view pixel with no black borders,
// resize and crop if needed
- (UIImage *) fillSize: (CGSize) viewsize
{
    CGSize size = self.size;
    
    // Choose the scale factor that requires the least scaling
    CGFloat scalex = viewsize.width / size.width;
    CGFloat scaley = viewsize.height / size.height;
    CGFloat scale = MAX(scalex, scaley);
    
    UIGraphicsBeginImageContext(viewsize);
    
    CGFloat width = size.width * scale;
    CGFloat height = size.height * scale;
    
    // Center the scaled image
    float dwidth = ((viewsize.width - width) / 2.0f);
    float dheight = ((viewsize.height - height) / 2.0f);
    
    CGRect rect = CGRectMake(dwidth, dheight, size.width * scale, size.height * scale);
    [self drawInRect:rect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
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

CGContextRef CreateARGBBitmapContext (CGSize size)
{
    // Create the new color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for the bitmap data
    void *bitmapData = malloc(size.width * size.height * 4);
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Error: Memory not allocated!");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    // Build an 8-bit per channel context
    CGContextRef context = CGBitmapContextCreate (bitmapData, size.width, size.height, 8, size.width * 4, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace );
    if (context == NULL)
    {
        fprintf (stderr, "Error: Context not created!");
        free (bitmapData);
        return NULL;
    }
    
    return context;
}

- (UInt8 *) createBitmap
{
    // Create bitmap data for the given image
    CGContextRef context = CreateARGBBitmapContext(self.size);
    if (context == NULL) return NULL;
    
    CGRect rect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    CGContextDrawImage(context, rect, self.CGImage);
    UInt8 *data = CGBitmapContextGetData(context);
    CGContextRelease(context);
    
    return data;
}

- (UIImage *) convolveImageWithEdgeDetection
{
    // Dimensions
    int theheight = floor(self.size.height);
    int thewidth =  floor(self.size.width);
    
    // Get input and create output bits
    UInt8 *inbits = (UInt8 *)[self createBitmap];
    UInt8 *outbits = (UInt8 *)malloc(theheight * thewidth * 4);
    
    // Basic Canny Edge Detection
    int matrix1[9] = {-1, 0, 1, -2, 0, 2, -1, 0, 1};
    int matrix2[9] = {-1, -2, -1, 0, 0, 0, 1, 2, 1};
    
    int radius = 1;
    
    // Iterate through each available pixel (leaving a radius-sized
    // boundary)
    for (int y = radius; y < (theheight - radius); y++)
        for (int x = radius; x < (thewidth - radius); x++)
        {
            int sumr1 = 0, sumr2 = 0;
            int sumg1 = 0, sumg2 = 0;
            int sumb1 = 0, sumb2 = 0;
            int offset = 0;
            for (int j = -radius; j <= radius; j++)
                for (int i = -radius; i <= radius; i++)
                {
                    sumr1 += inbits[redOffset(x+i, y+j, thewidth)] *
                    matrix1[offset];
                    sumr2 += inbits[redOffset(x+i, y+j, thewidth)] *
                    matrix2[offset];
                    
                    sumg1 += inbits[greenOffset(x+i, y+j, thewidth)] *
                    matrix1[offset];
                    sumg2 += inbits[greenOffset(x+i, y+j, thewidth)] *
                    matrix2[offset];
                    
                    sumb1 += inbits[blueOffset(x+i, y+j, thewidth)] *
                    matrix1[offset];
                    sumb2 += inbits[blueOffset(x+i, y+j, thewidth)] *
                    matrix2[offset];
                    offset++;
                }
            
            // Assign the outbits
            int sumr = MIN(((ABS(sumr1) + ABS(sumr2)) / 2), 255);
            int sumg = MIN(((ABS(sumg1) + ABS(sumg2)) / 2), 255);
            int sumb = MIN(((ABS(sumb1) + ABS(sumb2)) / 2), 255);
            
            outbits[redOffset(x, y, thewidth)] = (UInt8) sumr;
            outbits[greenOffset(x, y, thewidth)] = (UInt8)
            sumg;
            outbits[blueOffset(x, y, thewidth)] = (UInt8) sumb;
            outbits[alphaOffset(x, y, thewidth)] =
            (UInt8) inbits[alphaOffset(x, y, thewidth)];
        }
    
    // Release the original bitmap. imageWithBits frees outbits
    free(inbits);

    return [UIImage imageWithBits:outbits withSize:CGSizeMake(thewidth, theheight)];
}
@end

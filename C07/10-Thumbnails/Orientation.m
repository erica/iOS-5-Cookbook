/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "Orientation.h"

uint exifOrientationFromUIOrientation(UIImageOrientation uiorientation)
{
    if (uiorientation > 7) return 1;
    int orientations[8] = {1, 3, 6, 8, 2, 4, 5, 7};
    return orientations[uiorientation];
}

UIImageOrientation imageOrientationFromEXIFOrientation(uint exiforientation)
{
    if ((exiforientation < 1) || (exiforientation > 8)) return UIImageOrientationUp;    
    int orientations[8] = {0, 4, 1, 5, 6, 2, 7, 3};
    return orientations[exiforientation];
}

NSString *deviceOrientationName(UIDeviceOrientation orientation)
{
    NSArray *names = [NSArray 
                      arrayWithObjects:
                      @"Unknown",
                      @"Portrait",
                      @"Portrait Upside Down",
                      @"Landscape Left",
                      @"Landscape Right",
                      @"Face Up",
                      @"Face Down",
                      nil];
    return [names objectAtIndex:orientation];
}

NSString *currentDeviceOrientationName()
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    return deviceOrientationName(orientation);
}

NSString *imageOrientationNameFromOrientation(UIImageOrientation orientation)
{
    NSArray *names = [NSArray 
                      arrayWithObjects:
                      @"Up",
                      @"Down",
                      @"Left",
                      @"Right",
                      @"Up-Mirrored",
                      @"Down-Mirrored",
                      @"Left-Mirrored",
                      @"Right-Mirrored",
                      nil];
    return [names objectAtIndex:orientation];
}

NSString *exifOrientationNameFromOrientation(uint orientation)
{
    NSArray *names = [NSArray 
                      arrayWithObjects:
                      @"Undefined",
                      @"Top Left",
                      @"Top Right",
                      @"Bottom Right",
                      @"Bottom Left",
                      @"Left Top",
                      @"Right Top",
                      @"Right Bottom",
                      @"Left Bottom",
                      nil];
    return [names objectAtIndex:orientation];
}


NSString *imageOrientationName(UIImage *anImage)
{
    return imageOrientationNameFromOrientation(anImage.imageOrientation);
}

BOOL deviceIsLandscape()
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    return UIDeviceOrientationIsLandscape(orientation);
}

BOOL deviceIsPortrait()
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    return UIDeviceOrientationIsPortrait(orientation);
}

UIImageOrientation currentImageOrientationWithMirroring(BOOL isUsingFrontCamera)
{
    switch ([UIDevice currentDevice].orientation) 
    {
        case UIDeviceOrientationPortrait:
            return isUsingFrontCamera ? UIImageOrientationRight : UIImageOrientationLeftMirrored;
        case UIDeviceOrientationPortraitUpsideDown:
            return isUsingFrontCamera ? UIImageOrientationLeft :UIImageOrientationRightMirrored;
        case UIDeviceOrientationLandscapeLeft:
            return isUsingFrontCamera ? UIImageOrientationDown :  UIImageOrientationUpMirrored;
        case UIDeviceOrientationLandscapeRight:
            return isUsingFrontCamera ? UIImageOrientationUp : UIImageOrientationDownMirrored;
        default:
            return  UIImageOrientationUp;
    }
}

// Expected Image orientation from current orientation and camera in use
UIImageOrientation currentImageOrientation(BOOL isUsingFrontCamera, BOOL shouldMirrorFlip)
{
    if (shouldMirrorFlip) 
        return currentImageOrientationWithMirroring(isUsingFrontCamera);
    
    switch ([UIDevice currentDevice].orientation) 
    {
        case UIDeviceOrientationPortrait:
            return isUsingFrontCamera ? UIImageOrientationLeftMirrored : UIImageOrientationRight;
        case UIDeviceOrientationPortraitUpsideDown:
            return isUsingFrontCamera ? UIImageOrientationRightMirrored :UIImageOrientationLeft;
        case UIDeviceOrientationLandscapeLeft:
            return isUsingFrontCamera ? UIImageOrientationDownMirrored :  UIImageOrientationUp;
        case UIDeviceOrientationLandscapeRight:
            return isUsingFrontCamera ? UIImageOrientationUpMirrored :UIImageOrientationDown;
        default:
            return  UIImageOrientationUp;
    }
}

uint currentEXIFOrientation(BOOL isUsingFrontCamera, BOOL shouldMirrorFlip)
{
    return exifOrientationFromUIOrientation(currentImageOrientation(isUsingFrontCamera, shouldMirrorFlip));
}

// Does not take camera into account for both portrait orientations
// This is likely due to an ongoing bug
uint detectorEXIF(BOOL isUsingFrontCamera, BOOL shouldMirrorFlip)
{
    if (isUsingFrontCamera || deviceIsLandscape())
        return currentEXIFOrientation(isUsingFrontCamera, shouldMirrorFlip);
    
    // Only back camera portrait  or upside down here. This bugs me a lot.
    // Detection happens but the geometry is messed.
    int orientation = currentEXIFOrientation(!isUsingFrontCamera, shouldMirrorFlip);
    return orientation;
}

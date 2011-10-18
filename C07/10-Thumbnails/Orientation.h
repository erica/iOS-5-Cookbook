/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

/*
 
 HOME BUTTON CAMERA  OUTPUT  UNMIRRORED       MIRRORED         ORIENTATION
 Bottom      Front   Right   Left Mirrored    Right            Portrait
 Right       Front   Down    Down Mirrored    Down             LandscapeLeft
 Top         Front   Left    Right Mirrored   Left             PortraitUpsideDown
 Left        Front   Up      Up Mirrored      Up               LandscapeRight

 Bottom      Back    Right   Right            Left Mirrored    Portrait
 Right       Back    Up      Up               Up Mirrored      LandscapeLeft
 Top         Back    Left    Left             Right Mirrored   PortraitUpsideDown
 Left        Back    Down    Down             Down Mirrored    LandscapeRight
 
 AVAILABLE ORIENTATIONS: EXIF and UIImageOrientation
 
 topleft toprt   botrt  botleft   leftop      righttop     rightbot   leftbot
 EXIF 1    2       3      4         5            6           7          8
 
 XXXXXX  XXXXXX      XX  XX      XXXXXXXXXX  XX                  XX  XXXXXXXXXX
 XX          XX      XX  XX      XX  XX      XX  XX          XX  XX      XX  XX
 XXXX      XXXX    XXXX  XXXX    XX          XXXXXXXXXX  XXXXXXXXXX          XX
 XX          XX      XX  XX
 XX          XX  XXXXXX  XXXXXX
 
 UI 0      4       1      5         6            2           7           3       
    up    upmirror down  downmir leftmir      left         rightmir    right
 
 
 
 MAPPINGS BETWEEN ORIENTATIONS:
 
 {1, 3, 6, 8, 2, 4, 5, 7};  EXIF
 {0  1  2  3  4  5  6  7}   UIIMG
 
 {1  2  3  4  5  6  7  8}   EXIF
 {0, 4, 1, 5, 6, 2, 7, 3};  UIIMG

 */

// EXIF ORIENTATIONS
enum {
    kTopLeft			= 1, // UIImageOrientationUp,           (0,0) at top left
    kTopRight           = 2, // UIImageOrientationUpMirrored,   (0,0) at top right
    kBottomRight        = 3, // UIImageOrientationDown          (0,0) at bottom right
    kBottomLeft         = 4, // UIImageOrientationDownMirrored  (0,0) at bottom left
    kLeftTop            = 5, // UIImageOrientationLeftMirrored  (0,0) at left top
    kRightTop           = 6, // UIImageOrientationLeft          (0,0) at right top
    kRightBottom        = 7, // UIImageOrientationRightMirrored (0,0) at right bottom
    kLeftBottom         = 8  // UIImageOrientationRight         (0,0) at left bottom
} ExifOrientation;

/*
 
 UIIMAGE ORIENTATIONS
 
 typedef enum {
 UIImageOrientationUp =            0, // 0 deg rotation exif 1
 UIImageOrientationDown =          1, // 180 deg rotation exif 3
 UIImageOrientationLeft =          2, // 90 deg CCW exif 6
 UIImageOrientationRight =         3, // 90 deg CW exif 8
 UIImageOrientationUpMirrored =    4, // horizontal flip exif 2
 UIImageOrientationDownMirrored =  5, // horizontal flip exif 4
 UIImageOrientationLeftMirrored =  6, // vertical flip exif 5
 UIImageOrientationRightMirrored = 7, // vertical flip exif 7
 } UIImageOrientation;
 */

/*
 
 DEVICE ORIENTATIONS
 
 UIDeviceOrientationUnknown
     The orientation of the device cannot be determined.
 UIDeviceOrientationPortrait
     The device is in portrait mode, with the device held upright and the home button at the bottom.
 UIDeviceOrientationPortraitUpsideDown
     The device is in portrait mode but upside down, with the device held upright and the home button at the top.
 UIDeviceOrientationLandscapeLeft
     The device is in landscape mode, with the device held upright and the home button on the right side.
 UIDeviceOrientationLandscapeRight
     The device is in landscape mode, with the device held upright and the home button on the left side.
 UIDeviceOrientationFaceUp
     The device is held parallel to the ground with the screen facing upwards.
 UIDeviceOrientationFaceDown
     The device is held parallel to the ground with the screen facing downwards.
 */

// UTILITY FUNCTIONS

NSString *imageOrientationNameFromOrientation(UIImageOrientation orientation);
NSString *imageOrientationName(UIImage *anImage);
NSString *exifOrientationNameFromOrientation(uint orientation);
NSString *deviceOrientationName(UIDeviceOrientation orientation);
NSString *currentDeviceOrientationName();

BOOL deviceIsLandscape();
BOOL deviceIsPortrait();

uint exifOrientationFromUIOrientation(UIImageOrientation uiorientation);
UIImageOrientation imageOrientationFromEXIFOrientation(uint exiforientation);

UIImageOrientation currentImageOrientation(BOOL isUsingFrontCamera, BOOL shouldMirrorFlip);
uint currentEXIFOrientation(BOOL isUsingFrontCamera, BOOL shouldMirrorFlip);

// There is a huge bug in that portrait / back camera doesn't recognize 
// properly with its native EXIF alignment This function works around it 
// but you then have to adjust the geometry accordingly. Bah.
uint detectorEXIF(BOOL isUsingFrontCamera, BOOL shouldMirrorFlip);

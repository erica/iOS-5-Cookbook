//
//  exifGeometry.m
//  HelloWorld
//
//  Created by Erica Sadun on 7/18/11.
//  Copyright 2011 Up To No Good, Inc. All rights reserved.
//

#import "exifGeometry.h"

/*
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
 
 topleft toprt   botrt  botleft   leftop      righttop     rightbot   leftbot
 EXIF 1    2       3      4         5            6           7          8
 
 XXXXXX  XXXXXX      XX  XX      XXXXXXXXXX  XX                  XX  XXXXXXXXXX
 XX          XX      XX  XX      XX  XX      XX  XX          XX  XX      XX  XX
 XXXX      XXXX    XXXX  XXXX    XX          XXXXXXXXXX  XXXXXXXXXX          XX
 XX          XX      XX  XX
 XX          XX  XXXXXX  XXXXXX
 
 UI 0      4       1      5         6            2           7           3       
 up    upmirror down  downmir leftmir      left         rightmir    right

*/

CGPoint pointInEXIF(ExifOrientation exif, CGPoint aPoint, CGRect rect)
{
    switch(exif)
    {
        case kTopLeft: // vetted - back -- NOT FOR FRONT
            return CGPointMake(aPoint.x, rect.size.height - aPoint.y);
        case kTopRight: 
            return CGPointMake(rect.size.width - aPoint.x, rect.size.height - aPoint.y);
        case kBottomRight: // vetted - back
            return CGPointMake(rect.size.width - aPoint.x, aPoint.y);
        case kBottomLeft:
            return CGPointMake(aPoint.x, aPoint.y);

        case kLeftTop: // vetted - only for back -- NOT FOR FRONT
            return CGPointMake(aPoint.y, aPoint.x);
        case kRightTop: // untested
            return CGPointMake(aPoint.y, aPoint.x);
        case kRightBottom: // vetted - back
            return CGPointMake(rect.size.width - aPoint.y, rect.size.height - aPoint.x);
        case kLeftBottom: // untested
            return CGPointMake(rect.size.width - aPoint.y, rect.size.height - aPoint.x);
    }
}

CGSize sizeInEXIF(ExifOrientation exif, CGSize aSize)
{
    switch(exif)
    {
        case kTopLeft:
        case kTopRight:
        case kBottomRight:
        case kBottomLeft:
            return aSize;
            
        case kLeftTop:
        case kRightTop:
        case kRightBottom:
        case kLeftBottom:
            return CGSizeMake(aSize.height, aSize.width);
    }
}

CGRect rectInEXIF(ExifOrientation exif, CGRect inner, CGRect outer)
{
    CGRect rect;
    rect.origin = pointInEXIF(exif, inner.origin, outer);
    rect.size = sizeInEXIF(exif, inner.size);
    
    switch(exif)
    {
        case kTopLeft: // vetted
            rect = CGRectOffset(rect, 0.0f, -inner.size.height);
            break;
        case kTopRight: // vetted
            rect = CGRectOffset(rect, -inner.size.width, -inner.size.height);
            break;
        case kBottomRight: // vetted
            rect = CGRectOffset(rect, -inner.size.width, 0.0f);
            break;
        case kBottomLeft: // vetted
            break;
        case kLeftTop: // vetted 
            break;
        case kRightTop: // untested
            break;
        case kRightBottom: // vetted on back, NOT FOR FRONT
            rect = CGRectOffset(rect, -inner.size.width, -inner.size.height);
            break;
        case kLeftBottom: // untested
            break;
    }
    
    return rect;
}
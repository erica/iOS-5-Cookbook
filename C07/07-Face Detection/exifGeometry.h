/* PLEASE SEE https://github.com/erica/Camera-Image-Helper FOR UPDATED MATERIAL */
//
//  exifGeometry.h
//  HelloWorld
//
//  Created by Erica Sadun on 7/18/11.
//  Copyright 2011 Up To No Good, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Orientation.h"
#import "Geometry.h"

CGPoint pointInEXIF(ExifOrientation exif, CGPoint aPoint, CGRect rect);
CGSize sizeInEXIF(ExifOrientation exif, CGSize aSize);
CGRect rectInEXIF(ExifOrientation exif, CGRect inner, CGRect outer);

//
//  Thumb.m
//  HelloWorld
//
//  Created by Erica Sadun on 7/22/11.
//  Copyright 2011 Up To No Good, Inc. All rights reserved.
//

#import "Thumb.h"

// Draw centered text into the context
void centerText(CGContextRef context, NSString *fontname, float textsize, NSString *text, CGPoint point, UIColor *color)
{
    CGContextSaveGState(context);
    CGContextSelectFont(context, [fontname UTF8String], textsize, kCGEncodingMacRoman);
    
    // Retrieve the text width without actually drawing anything
    CGContextSaveGState(context);
    CGContextSetTextDrawingMode(context, kCGTextInvisible);
    CGContextShowTextAtPoint(context, 0.0f, 0.0f, [text UTF8String], text.length);
    CGPoint endpoint = CGContextGetTextPosition(context);
    CGContextRestoreGState(context);
    
    // Query for size to recover height. Width is less reliable
    CGSize stringSize = [text sizeWithFont:[UIFont fontWithName:fontname size:textsize]];
    
    // Draw the text
    [color setFill];
    CGContextSetShouldAntialias(context, true);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetTextMatrix (context, CGAffineTransformMake(1, 0, 0, -1, 0, 0));
    CGContextShowTextAtPoint(context, point.x - endpoint.x / 2.0f, point.y + stringSize.height / 4.0f, [text UTF8String], text.length); 
    CGContextRestoreGState(context);
}

// Create a thumb image using a grayscale/numeric level
UIImage *thumbWithLevel (float aLevel)
{
    float INSET_AMT = 1.5f;
    CGRect baseRect = CGRectMake(0.0f, 0.0f, 40.0f, 100.0f);
    CGRect thumbRect = CGRectMake(0.0f, 40.0f, 40.0f, 20.0f);
    
    UIGraphicsBeginImageContext(baseRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Create a filled rect for the thumb
    [[UIColor darkGrayColor] setFill];
    CGContextAddRect(context, CGRectInset(thumbRect, INSET_AMT, INSET_AMT));
    CGContextFillPath(context);
    
    // Outline the thumb
    [[UIColor whiteColor] setStroke];
    CGContextSetLineWidth(context, 2.0f);    
    CGContextAddRect(context, CGRectInset(thumbRect, 2.0f * INSET_AMT, 2.0f * INSET_AMT));
    CGContextStrokePath(context);
    
    // Create a filled ellipse for the indicator
    CGRect ellipseRect = CGRectMake(0.0f, 0.0f, 40.0f, 40.0f);
    [[UIColor colorWithWhite:aLevel alpha:1.0f] setFill];
    CGContextAddEllipseInRect(context, ellipseRect);
    CGContextFillPath(context);
    
    // Label with a number
    NSString *numstring = [NSString stringWithFormat:@"%0.1f", aLevel];
    UIColor *textColor = (aLevel > 0.5f) ? [UIColor blackColor] : [UIColor whiteColor];
    centerText(context, @"Georgia", 20.0f, numstring, CGPointMake(20.0f, 20.0f), textColor);
    
    // Outline the indicator circle
    [[UIColor grayColor] setStroke];
    CGContextSetLineWidth(context, 3.0f);    
    CGContextAddEllipseInRect(context, CGRectInset(ellipseRect, 2.0f, 2.0f));
    CGContextStrokePath(context);
    
    // Build and return the image
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

// Return a base thumb image without the bubble
UIImage *simpleThumb()
{
    float INSET_AMT = 1.5f;
    CGRect baseRect = CGRectMake(0.0f, 0.0f, 40.0f, 100.0f);
    CGRect thumbRect = CGRectMake(0.0f, 40.0f, 40.0f, 20.0f);
    
    UIGraphicsBeginImageContext(baseRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Create a filled rect for the thumb
    [[UIColor darkGrayColor] setFill];
    CGContextAddRect(context, CGRectInset(thumbRect, INSET_AMT, INSET_AMT));
    CGContextFillPath(context);
    
    // Outline the thumb
    [[UIColor whiteColor] setStroke];
    CGContextSetLineWidth(context, 2.0f);    
    CGContextAddRect(context, CGRectInset(thumbRect, 2.0f * INSET_AMT, 2.0f * INSET_AMT));
    CGContextStrokePath(context);
    
    // Retrieve the thumb
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
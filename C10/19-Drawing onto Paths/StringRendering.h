//
//  StringRendering.h
//  HelloWorld
//
//  Created by Erica Sadun on 7/29/11.
//  Copyright 2011 Up To No Good, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface StringRendering : NSObject
@property (assign) CGFloat inset;
@property (strong) UIView *view;
@property (strong) NSAttributedString *string;
+ (id) rendererForView: (UIView *) aView string: (NSAttributedString *) aString;

- (void) prepareContextForCoreText;
- (void) drawInRect: (CGRect) theRect;
- (void) drawInPath: (CGMutablePathRef) path;
- (void) drawOnPoints: (NSArray *) points;
- (void) drawOnBezierPath: (UIBezierPath *) path;
@end

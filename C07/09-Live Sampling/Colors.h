//
//  Colors.h
//  HelloWorld
//
//  Created by Erica Sadun on 7/18/11.
//  Copyright 2011 Up To No Good, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

void rgbtohsb(CGFloat r, CGFloat g, CGFloat b, CGFloat *pH, CGFloat *pS, CGFloat *pV);
void hsbtorgb(CGFloat h, CGFloat s, CGFloat v, CGFloat *pR, CGFloat *pG, CGFloat *pB);
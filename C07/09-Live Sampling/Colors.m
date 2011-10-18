//
//  Colors.m
//  HelloWorld
//
//  Created by Erica Sadun on 7/18/11.
//  Copyright 2011 Up To No Good, Inc. All rights reserved.
//

#import "Colors.h"

void rgbtohsb(CGFloat r, CGFloat g, CGFloat b, CGFloat *pH, CGFloat *pS, CGFloat *pV)
{
	CGFloat h,s,v;
	
	// From Foley and Van Dam
	CGFloat max = MAX(r, MAX(g, b));
	CGFloat min = MIN(r, MIN(g, b));
	
	// Brightness
	v = max;
	
	// Saturation
	s = (max != 0.0f) ? ((max - min) / max) : 0.0f;
	
	if (s == 0.0f) {
		// No saturation, so undefined hue
		h = 0.0f;
	} else {
		// Determine hue
		CGFloat rc = (max - r) / (max - min);		// Distance of color from red
		CGFloat gc = (max - g) / (max - min);		// Distance of color from green
		CGFloat bc = (max - b) / (max - min);		// Distance of color from blue
		
		if (r == max) h = bc - gc;					// resulting color between yellow and magenta
		else if (g == max) h = 2 + rc - bc;			// resulting color between cyan and yellow
		else /* if (b == max) */ h = 4 + gc - rc;	// resulting color between magenta and cyan
		
		h *= 60.0f;									// Convert to degrees
		if (h < 0.0f) h += 360.0f;					// Make non-negative
	}
	
	if (pH) *pH = h;
	if (pS) *pS = s;
	if (pV) *pV = v;
}

void hsbtorgb(CGFloat h, CGFloat s, CGFloat v, CGFloat *pR, CGFloat *pG, CGFloat *pB)
{
	CGFloat r = 0.0f;
	CGFloat g = 0.0f;
	CGFloat b = 0.0f;
	
	// From Foley and Van Dam
	
	if (s == 0.0f) {
		// Achromatic color: there is no hue
		r = g = b = v;
	} else {
		// Chromatic color: there is a hue
		if (h == 360.0f) h = 0.0f;
		h /= 60.0f;										// h is now in [0, 6)
		
		int i = floorf(h);								// largest integer <= h
		CGFloat f = h - i;								// fractional part of h
		CGFloat p = v * (1 - s);
		CGFloat q = v * (1 - (s * f));
		CGFloat t = v * (1 - (s * (1 - f)));
		
		switch (i) {
			case 0:	r = v; g = t; b = p;	break;
			case 1:	r = q; g = v; b = p;	break;
			case 2:	r = p; g = v; b = t;	break;
			case 3:	r = p; g = q; b = v;	break;
			case 4:	r = t; g = p; b = v;	break;
			case 5:	r = v; g = p; b = q;	break;
		}
	}
	
	if (pR) *pR = r;
	if (pG) *pG = g;
	if (pB) *pB = b;
}

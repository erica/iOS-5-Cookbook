//
//  StringRendering.m
//  HelloWorld
//
//  Created by Erica Sadun on 7/29/11.
//  Copyright 2011 Up To No Good, Inc. All rights reserved.
//

#import "StringRendering.h"
#import "StringHelper.h"

@implementation StringRendering
@synthesize string, view, inset;
+ (id) rendererForView: (UIView *) aView string: (NSAttributedString *) aString
{
    StringRendering *renderer = [[self alloc] init];
    renderer.view = aView;
    renderer.string = aString;
    return renderer;
}

// Prepare a flipped context
- (void) prepareContextForCoreText
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, view.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0); // flip the context
}

// Adjust the drawing rectangle to compensate for the flipped context
- (CGRect) adjustedRect: (CGRect) rect
{
    CGRect newRect = rect;
    CGFloat newYOrigin = view.frame.size.height - (rect.size.height + rect.origin.y);
    newRect.origin.y = newYOrigin;
    return newRect;
}

// Add text to rectangle
- (void) drawInRect: (CGRect) theRect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect insetRect = CGRectInset(theRect, inset, inset);
	CGRect rect = [self adjustedRect: insetRect];
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, NULL, rect);
    
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)string);
	CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, string.length), path, NULL);
	
	CTFrameDraw(theFrame, context);
	
	CFRelease(framesetter);
	CFRelease(theFrame);
	CFRelease(path);
}

// Draw in path
- (void) drawInPath: (CGMutablePathRef) path
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)string);
	CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, string.length), path, NULL);
	
	CTFrameDraw(theFrame, context);
	
	CFRelease(framesetter);
	CFRelease(theFrame);
	CFRelease(path);	

}

// Return distance between two points
float distance (CGPoint p1, CGPoint p2)
{
	float dx = p2.x - p1.x;
	float dy = p2.y - p1.y;
	
	return sqrt(dx*dx + dy*dy);
}

- (void) drawOnPoints: (NSArray *) points
{
	int pointCount = points.count;
	if (pointCount < 2) return;
    
    // CALCULATIONS
    
    // calculate the length of the point path
	float totalPointLength = 0.0f;
	for (int i = 1; i < pointCount; i++)
		totalPointLength += distance([[points objectAtIndex:i] CGPointValue], [[points objectAtIndex:i-1] CGPointValue]);
	
	// Create the typographic line
	CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)string);
	if (!line) return;
	double lineLength = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
	
	// Retrieve the runs
	CFArrayRef runArray = CTLineGetGlyphRuns(line);
	
	// Count the items
	int glyphCount = 0; //  Number of glyphs encountered
	float runningWidth; //  running width tally
	int glyphNum = 0;   //  Current glyph
	for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++) 
	{
		CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
		for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++) 
		{
			runningWidth += CTRunGetTypographicBounds(run, CFRangeMake(runGlyphIndex, 1), NULL, NULL, NULL);
			if (!glyphNum && (runningWidth > totalPointLength))
				glyphNum = glyphCount;
			glyphCount++;
		}
	}
    
    // Use total length to calculate the percent of path consumed at each point
	NSMutableArray *pointPercentArray = [NSMutableArray array];
	[pointPercentArray addObject:[NSNumber numberWithFloat:0.0f]];
	float distanceTravelled = 0.0f;
	for (int i = 1; i < pointCount; i++)
	{
		distanceTravelled += distance([[points objectAtIndex:i] CGPointValue], [[points objectAtIndex:i-1] CGPointValue]);
		[pointPercentArray addObject:[NSNumber numberWithFloat:(distanceTravelled / totalPointLength)]];
	}
	
	// Add a final item just to stop with. Probably not needed. 
	[pointPercentArray addObject:[NSNumber numberWithFloat:2.0f]];
    
    
    // PREPARE FOR DRAWING
    
    NSRange subrange = {0, glyphNum};
    NSAttributedString *newString = [string attributedSubstringFromRange:subrange];
    
	// Re-establish line and run array
	if (glyphNum)
	{
		CFRelease(line);
        
		line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)newString);
		if (!line) {NSLog(@"Error re-creating line"); return;}
		
		lineLength = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
		runArray = CTLineGetGlyphRuns(line);
	}
 
	// Keep a running tab of how far the glyphs have travelled to
	// be able to calculate the percent along the point path
	float glyphDistance = 0.0f;
		
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // Set the initial positions
    CGPoint textPosition = CGPointMake(0.0f, 0.0f);
	CGContextSetTextPosition(context, textPosition.x, textPosition.y);
    
    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++) 
	{
		// Retrieve the run
		CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
		
        // Retrieve font and color
		CFDictionaryRef attributes = CTRunGetAttributes(run);
		CTFontRef runFont = CFDictionaryGetValue(attributes, kCTFontAttributeName);
		CGColorRef fontColor = (CGColorRef) CFDictionaryGetValue(attributes, kCTForegroundColorAttributeName);
		CFShow(attributes);
		if (fontColor) [[UIColor colorWithCGColor:fontColor] set];
		
		// Iterate through each glyph in the run
		for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++) 
		{
			// Calculate the percent travel
			float glyphWidth = CTRunGetTypographicBounds(run, CFRangeMake(runGlyphIndex, 1), NULL, NULL, NULL);			
			float percentConsumed = glyphDistance / lineLength;
            
			// Find a corresponding pair of points in the path
			CFIndex index = 1;
			while ((index < pointPercentArray.count) && 
				   (percentConsumed > [[pointPercentArray objectAtIndex:index] floatValue]))
				index++;
			
			// Don't try to draw if we're out of data. This should not happen.
			if (index > (points.count - 1)) continue;
			
			// Calculate the intermediate distance between the two points
			CGPoint point1 = [[points objectAtIndex:index - 1] CGPointValue];
			CGPoint point2 = [[points objectAtIndex:index] CGPointValue];
            
			float percent1 = [[pointPercentArray objectAtIndex:index - 1] floatValue];
			float percent2 = [[pointPercentArray objectAtIndex:index] floatValue];
			float percentOffset = (percentConsumed - percent1) / (percent2 - percent1);
            
			float dx = point2.x - point1.x;
			float dy = point2.y - point1.y;
			
			CGPoint targetPoint = CGPointMake(point1.x + (percentOffset * dx), (point1.y + percentOffset * dy));
			targetPoint.y = view.bounds.size.height - targetPoint.y;
            
			// Set the x and y offset
			CGContextTranslateCTM(context, targetPoint.x, targetPoint.y);
			CGPoint positionForThisGlyph = CGPointMake(textPosition.x, textPosition.y);
			
			// Rotate
			float angle = -atan(dy / dx);
			if (dx < 0) angle += M_PI; // going left, update the angle
			CGContextRotateCTM(context, angle);
			
			// Apply text matrix transform
			textPosition.x -= glyphWidth;
			CGAffineTransform textMatrix = CTRunGetTextMatrix(run);
			textMatrix.tx = positionForThisGlyph.x;
			textMatrix.ty = positionForThisGlyph.y;
			CGContextSetTextMatrix(context, textMatrix);
			
			// Draw the glyph
			CGGlyph glyph;
			CGPoint position;
			CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
			CFRange glyphRange = CFRangeMake(runGlyphIndex, 1);
			CTRunGetGlyphs(run, glyphRange, &glyph);
			CTRunGetPositions(run, glyphRange, &position);
			CGContextSetFont(context, cgFont);
			CGContextSetFontSize(context, CTFontGetSize(runFont));
			CGContextShowGlyphsAtPositions(context, &glyph, &position, 1);
			
			CFRelease(cgFont);
			
			// Reset context transforms
			CGContextRotateCTM(context, -angle);
			CGContextTranslateCTM(context, -targetPoint.x, -targetPoint.y);
			
			glyphDistance += glyphWidth;
		}
	}
	
	CFRelease(line);
	CGContextRestoreGState(context);
}

#define VALUE(_INDEX_) [NSValue valueWithCGPoint:points[_INDEX_]]

// Get points from Bezier Curve
void _getPointsFromBezier(void *info, const CGPathElement *element) 
{
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;    
    
    // Retrieve the path element type and its points
    CGPathElementType type = element->type;
    CGPoint *points = element->points;
    
    // Add the points if they're available (per type)
    if (type != kCGPathElementCloseSubpath)
    {
        [bezierPoints addObject:VALUE(0)];
        if ((type != kCGPathElementAddLineToPoint) &&
            (type != kCGPathElementMoveToPoint))
            [bezierPoints addObject:VALUE(1)];
    }    
    if (type == kCGPathElementAddCurveToPoint)
        [bezierPoints addObject:VALUE(2)];
}

NSArray *_pointsFromBezierPath(UIBezierPath *bpath)
{
    NSMutableArray *points = [NSMutableArray array];
    CGPathApply(bpath.CGPath, (__bridge void *)points, _getPointsFromBezier);
    return points;
}

- (void) drawOnBezierPath: (UIBezierPath *) path
{
    NSArray *points = _pointsFromBezierPath(path);
    [self drawOnPoints:points];
}

@end

//
//  TOUCHkitView.m
//  HelloWorld
//
//  Created by Erica Sadun on 12/3/09.
//  Copyright 2009 Up To No Good, Inc.. All rights reserved.
//

#import "TOUCHkitView.h"

UIImage *fingers;

@implementation TOUCHkitView
@synthesize touchColor;

static TOUCHkitView *sharedInstance = nil;

+ (id) sharedInstance 
{
    // Create shared instance if it does not yet exist
    if(!sharedInstance)
    {
		sharedInstance = [[self alloc] initWithFrame:CGRectZero];
    }
    
    // Parent it to the key window
    if (!sharedInstance.superview)
    {
        UIWindow *keyWindow= [UIApplication sharedApplication].keyWindow;
        sharedInstance.frame = keyWindow.bounds;
        [keyWindow addSubview:sharedInstance];
    }
    
    return sharedInstance;
}


// You can override the default color if you want using touchColor property
- (id) initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        self.multipleTouchEnabled = YES;
        touchColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
		touches = nil;
	}
	
	return self;
}

// Basic Touches processing

- (void) touchesBegan:(NSSet *)theTouches withEvent:(UIEvent *)event
{
	touches = theTouches;
	[self setNeedsDisplay];
}

- (void) touchesMoved:(NSSet *)theTouches withEvent:(UIEvent *)event
{
	touches = theTouches;
	[self setNeedsDisplay];
}

- (void) touchesEnded:(NSSet *)theTouches withEvent:(UIEvent *)event
{
	touches = nil;
	[self setNeedsDisplay];
}

// Draw touches interactively
- (void) drawRect: (CGRect) rect
{
    // Clear
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, self.bounds);
	
    // Fill see-through
	[[UIColor clearColor] set];
	CGContextFillRect(context, self.bounds);
	
	float size = 25.0f; // based on 44.0f standard touch point
	
    for (UITouch *touch in touches)
    {
        [[[UIColor darkGrayColor] colorWithAlphaComponent:0.5f] set];
        CGPoint aPoint = [touch locationInView:self];
        CGContextAddEllipseInRect(context, CGRectMake(aPoint.x - size, aPoint.y - size, 2 * size, 2 * size));
        CGContextFillPath(context);
        
        float dsize = 1.0f;
        [touchColor set];
        aPoint = [touch locationInView:self];
        CGContextAddEllipseInRect(context, CGRectMake(aPoint.x - size - dsize, aPoint.y - size - dsize, 2 * (size - dsize), 2 * (size - dsize)));
        CGContextFillPath(context);
    }

    // Reset touches after use
    touches = nil;
}
@end
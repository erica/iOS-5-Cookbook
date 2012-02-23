/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "MapAnnotation.h"

@implementation MapAnnotation
@synthesize coordinate, title, subtitle;
@synthesize tag;

- (id) initWithCoordinate: (CLLocationCoordinate2D) aCoordinate
{
	if (self = [super init]) 
        coordinate = aCoordinate;
	return self;
}
@end

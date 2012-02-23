/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapAnnotation : NSObject <MKAnnotation>
- (id) initWithCoordinate: (CLLocationCoordinate2D) aCoordinate;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) NSUInteger tag;
@end

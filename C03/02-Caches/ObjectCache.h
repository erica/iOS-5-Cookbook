/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

@interface ObjectCache : NSObject
@property (nonatomic, retain) NSMutableDictionary *myCache;
@property (nonatomic, assign) int allocationSize;

+ (ObjectCache *) cache;
- (id) retrieveObjectNamed: (NSString *) someKey;
- (void) respondToMemoryWarning;
@end

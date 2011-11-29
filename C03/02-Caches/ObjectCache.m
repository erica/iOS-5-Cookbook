/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "ObjectCache.h"

@implementation ObjectCache
@synthesize myCache, allocationSize;

+ (ObjectCache *) cache
{
	return [[ObjectCache alloc] init];
}

// Fake loading an object by creating NSData of the given size
- (id) loadObjectNamed: (NSString *) someKey
{
    if (!allocationSize)
        allocationSize = 1024 * 1024;

    char *foo = malloc(allocationSize);
    NSData *data = [NSData dataWithBytes:foo length:allocationSize];
    free(foo);
    return data;
}

// When an object is not found, it's loaded
- (id) retrieveObjectNamed: (NSString *) someKey
{
    if (!myCache) 
        self.myCache = [NSMutableDictionary dictionary];
	id object = [myCache objectForKey:someKey];
	if (!object) 
	{
		if ((object = [self loadObjectNamed:someKey]))
            [myCache setObject:object forKey:someKey];
	}
	return object;
}

// Clear the cache at a memory warning
- (void) respondToMemoryWarning
{
	[myCache removeAllObjects];
}
@end

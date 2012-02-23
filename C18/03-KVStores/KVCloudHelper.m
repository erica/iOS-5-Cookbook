/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "KVCloudHelper.h"

#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)

@implementation KVCloudHelper
@synthesize delegate;
- (id)init
{
    if (!(self = [super init])) return self;
    
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:NSUbiquitousKeyValueStoreDidChangeExternallyNotification 
     object:nil queue:[NSOperationQueue mainQueue] 
     usingBlock:^(NSNotification __strong *notification) {
        NSDictionary *userInfo = [notification userInfo];

        NSUInteger reason = [[userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey] intValue];
        NSArray *keys = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey];

        // Perform updates only if there is a delegate to listen
        if (!delegate) return;
        
        if (reason == NSUbiquitousKeyValueStoreServerChange)
        {
            if (keys.count == 1)
                SAFE_PERFORM_WITH_ARG(delegate, @selector(kvStoreUpdatedForKey:), [keys lastObject]);
            else if (keys.count)
                SAFE_PERFORM_WITH_ARG(delegate, @selector(kvStoreUpdatedForKeys:), keys);
            
            SAFE_PERFORM_WITH_ARG(delegate, @selector(kvStoreUpdated), nil);
        }
        else if (reason == NSUbiquitousKeyValueStoreInitialSyncChange)
            SAFE_PERFORM_WITH_ARG(delegate, @selector(kvStorePerformedInitialSync), nil);
        else if (reason == NSUbiquitousKeyValueStoreQuotaViolationChange)
            SAFE_PERFORM_WITH_ARG(delegate, @selector(kvStoreViolatedQuota), nil);
    }];

    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

@interface APNSHelper : NSObject 
@property (nonatomic, strong)	NSString *deviceTokenID;
@property (nonatomic, strong)	NSData *certificateData;
@property (assign) BOOL useSandboxServer;

+ (APNSHelper *) sharedInstance;
- (BOOL) push: (NSString *) payload;
- (NSArray *) fetchFeedback;
@end

/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


#import <Foundation/Foundation.h>

@interface ProgressAlert : NSObject
+ (void) presentProgress: (float) amount withText: (NSString *) alertText;
+ (void) dismiss;
+ (void) setProgress: (float) amount;
+ (void) setTitle: (NSString *) aTitle;
+ (void) setMessage: (NSString *) aMessage;
@end

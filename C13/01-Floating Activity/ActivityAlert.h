/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


#import <Foundation/Foundation.h>

@interface ActivityAlert : NSObject
+ (void) presentWithText: (NSString *) alertText;
+ (void) dismiss;
+ (void) setTitle: (NSString *) aTitle;
+ (void) setMessage: (NSString *) aMessage;
@end

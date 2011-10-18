/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface MarkupHelper : NSObject
+ (NSAttributedString *) stringFromMarkup: (NSString *) markupString;
@end

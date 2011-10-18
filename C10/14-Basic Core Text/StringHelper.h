/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>


@interface StringHelper : NSObject 
@property (nonatomic, strong) NSMutableAttributedString *string;

@property (nonatomic, strong) NSString *fontName;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, strong) UIColor *foregroundColor;
@property (nonatomic, strong) NSString *alignment;
@property (nonatomic, strong) NSString *breakMode;

+ (id) buildHelper;
- (void) appendFormat: (NSString *) formatstring, ...;
@end

/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>
@interface TwitPicOperation : NSOperation 
@property (strong) NSData *imageData;
@property (weak) id delegate;
+ (id) operationWithDelegate: (id) delegate andPath: (NSString *) path;
@end

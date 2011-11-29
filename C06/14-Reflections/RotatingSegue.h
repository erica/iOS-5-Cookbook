/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

// Two-way segue allows you to move in either direction
// Informal delegate sends segueDidComplete message

@interface RotatingSegue : UIStoryboardSegue
@property (assign) BOOL goesForward;
@property (assign) UIViewController *delegate;
@end

//
//  VIDEOkit.h
//  HelloWorld
//
//  Created by Erica Sadun on 5/12/10.
//  Copyright 2010 Up To No Good, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface VIDEOkit : NSObject 
{
	UIImageView *baseView;	
}
@property (nonatomic, weak)   UIViewController *delegate;
@property (nonatomic, strong) UIWindow *outwindow;
@property (nonatomic, strong) CADisplayLink *displayLink;

+ (void) startupWithDelegate: (id) aDelegate;
@end

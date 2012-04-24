//
//  TOUCHkitView.h
//  HelloWorld
//
//  Created by Erica Sadun on 12/3/09.
//  Copyright 2009 Up To No Good, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TOUCHkitView : UIView 
{
	NSSet *touches;
}
@property (strong) UIColor *touchColor;

+ (id) sharedInstance;
@end

//
//  StarSlider.h
//  HelloWorld
//
//  Created by Erica Sadun on 2/25/10.
//  Copyright 2010 Up To No Good, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StarSlider : UIControl
{
	int value; // from 0 to 5
}
@property (nonatomic, assign) int value;
+ (id) control;
@end

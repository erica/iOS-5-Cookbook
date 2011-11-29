//
//  BookController.h
//  HelloWorld
//
//  Created by Erica Sadun on 7/5/11.
//  Copyright 2011 Up To No Good, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

// Used for storing the most recent book page used
#define DEFAULTS_BOOKPAGE   @"BookControllerMostRecentPage"

@protocol BookControllerDelegate <NSObject>
- (id) viewControllerForPage: (int) pageNumber;
@optional
- (void) bookControllerDidTurnToPage: (NSNumber *) pageNumber;
@end

@interface BookController : UIPageViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>
+ (id) bookWithDelegate: (id) theDelegate;
+ (id) rotatableViewController;
- (void) moveToPage: (uint) requestedPage;
- (int) currentPage;

@property (nonatomic, weak) id <BookControllerDelegate> bookDelegate;
@property (nonatomic, assign) uint pageNumber;
@end
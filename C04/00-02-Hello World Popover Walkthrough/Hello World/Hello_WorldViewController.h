//
//  Hello_WorldViewController.h
//  Hello World
//
//  Created by Erica Sadun on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Hello_WorldViewController : UIViewController <UIPopoverControllerDelegate>
- (IBAction)dismissModalController:(id)sender;
@property (strong) UIPopoverController *popoverController;
@end


//
//  Hello_WorldViewController.m
//  Hello World
//
//  Created by Erica Sadun on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Hello_WorldViewController.h"

@implementation Hello_WorldViewController
@synthesize popoverController;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender 
{
    // existing popover
    if (self.popoverController)
    {
        [self.popoverController dismissPopoverAnimated:NO];
        self.popoverController = nil;
    }
        
    // retain the popover
    if ([segue.identifier isEqualToString:@"basic pop"]) 
    {
        UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue *)segue;
        UIPopoverController *thePopoverController = [popoverSegue popoverController];
        thePopoverController.contentViewController.contentSizeForViewInPopover = CGSizeMake(320.0f, 320.0f);        
        [thePopoverController setDelegate:self];
        self.popoverController = thePopoverController;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)thePopoverController {
    self.popoverController = nil;
}

- (IBAction)dismissModalController:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    
    return YES;
}
@end

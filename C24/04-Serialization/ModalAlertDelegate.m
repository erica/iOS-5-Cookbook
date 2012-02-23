/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "ModalAlertDelegate.h"

@implementation ModalAlertDelegate

- (id)initWithAlert: (UIAlertView *) anAlert
{
    if (!(self = [super init])) return self;    
    alertView = anAlert;
    return self;
}

-(void)alertView:(UIAlertView*)aView clickedButtonAtIndex:(NSInteger)anIndex 
{
    index = anIndex;
    alertView = nil;
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (int) show
{
    [alertView setDelegate:self];
    [alertView show];
    
    CFRunLoopRun();

    return index;
}

+ (id) delegateWithAlert: (UIAlertView *) anAlert
{
    ModalAlertDelegate *mad = [[self alloc] initWithAlert:anAlert];
    return mad;
}
@end

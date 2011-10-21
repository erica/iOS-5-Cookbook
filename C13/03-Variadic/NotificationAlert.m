/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "NotificationAlert.h"

@implementation NotificationAlert
+ (void) say: (id)formatstring,...
{
    if (!formatstring) return;
    
    va_list arglist;
    va_start(arglist, formatstring);
    id statement = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
    va_end(arglist);
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:statement message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [av show];
}
@end

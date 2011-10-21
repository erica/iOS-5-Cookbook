/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


#import "ActivityAlert.h"

static UIAlertView *alertView = nil;
static UIActivityIndicatorView *activity = nil;

@implementation ActivityAlert
+ (void) presentWithText: (NSString *) alertText
{
    if (alertView)
    {
        alertView.title = alertText;
        [alertView show];
    }
    else
    {
        alertView = [[UIAlertView alloc] initWithTitle:alertText message:@"\n\n\n\n\n\n" delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
        [alertView show];        
        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activity.center = CGPointMake(CGRectGetMidX(alertView.bounds), CGRectGetMidY(alertView.bounds));
        [activity startAnimating];
        [alertView addSubview: activity];
    }
}

+ (void) setTitle: (NSString *) aTitle
{
    alertView.title = aTitle;
}

+ (void) setMessage: (NSString *) aMessage;
{
    NSString *message = aMessage;
    while ([message componentsSeparatedByString:@"\n"].count < 7)
        message = [message stringByAppendingString:@"\n"];
    alertView.message = message;
}

+ (void) dismiss
{
    if (alertView)
    {
        [alertView dismissWithClickedButtonIndex:0 animated:YES];

        [activity removeFromSuperview];
        activity = nil;        
        alertView = nil;
    }
}
@end

/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


#import "ProgressAlert.h"

static UIAlertView *alertView = nil;
static UIProgressView *progress = nil;
@implementation ProgressAlert
+ (void) presentProgress: (float) amount withText: (NSString *) alertText
{
    if (alertView)
    {
        alertView.title = alertText;
        progress.progress = amount;
        [alertView show];
    }
    else
    {
        alertView = [[UIAlertView alloc] initWithTitle:alertText message:@"\n\n\n\n\n\n" delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
        [alertView show];        
        progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        progress.center = CGPointMake(CGRectGetMidX(alertView.bounds), CGRectGetMidY(alertView.bounds));
        progress.progress = amount;
        
        [alertView addSubview: progress];
    }
}

+ (void) setProgress: (float) amount
{
    progress.progress = amount;
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

        [progress removeFromSuperview];
        progress = nil;        
        alertView = nil;
    }
}
@end

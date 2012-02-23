/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "Utility.h"

void showAlert(id formatstring,...)
{
	if (!formatstring) return;
    
	va_list arglist;
	va_start(arglist, formatstring);
    id outstring = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
	
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:outstring message:nil delegate:nil cancelButtonTitle:@"Okay"otherButtonTitles:nil];
	[alertView show];
}


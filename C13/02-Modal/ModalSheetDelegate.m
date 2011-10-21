/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "ModalSheetDelegate.h"

@implementation ModalSheetDelegate
- (id)initWithSheet: (UIActionSheet *) aSheet
{
    if (!(self = [super init])) return self;    
    actionSheet = aSheet;
    return self;
}

- (void) actionSheet:(UIActionSheet *)anActionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    index = buttonIndex;
    actionSheet = nil;
    CFRunLoopStop(CFRunLoopGetCurrent());    
}

- (int) showFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated
{
    [actionSheet setDelegate:self];
    [actionSheet showFromBarButtonItem:item animated:animated];

    CFRunLoopRun();
    
    return index;
}

- (int) showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated
{
    [actionSheet setDelegate:self];
    [actionSheet showFromRect:rect inView:view animated:animated];
    
    CFRunLoopRun();
    
    return index;
}

- (int) showFromTabBar:(UITabBar *)view
{
    [actionSheet setDelegate:self];
    [actionSheet showFromTabBar:view];
    
    CFRunLoopRun();
    
    return index;
}

- (int) showFromToolbar:(UIToolbar *)view
{
    [actionSheet setDelegate:self];
    [actionSheet showFromToolbar:view];
    
    CFRunLoopRun();
    
    return index;
}

- (int) showInView:(UIView *)view
{
    [actionSheet setDelegate:self];
    [actionSheet showInView:view];
    
    CFRunLoopRun();
    
    return index;
}

+ (id) delegateWithSheet: (UIActionSheet *) aSheet
{
    ModalSheetDelegate *mas = [[self alloc] initWithSheet: aSheet];
    return mas;
}
@end

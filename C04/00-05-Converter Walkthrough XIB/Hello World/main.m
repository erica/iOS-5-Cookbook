//
//  main.m
//  Hello World
//
//  Created by Erica Sadun on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BARBUTTON(TITLE, SELECTOR)     [[UIBarButtonItem alloc] \
initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self \
action:SELECTOR]

@interface HelloWorldController : UIViewController 
{
    UITextField *field1;
    UITextField *field2;
}
@end

@implementation HelloWorldController
- (void) convert: (id) sender
{
    float invalue = [[field1 text] floatValue];
    float outvalue = (invalue - 32.0f) * 5.0f / 9.0f;
    [field2 setText:[NSString stringWithFormat:@"%3.2f", outvalue]];
    [field1 resignFirstResponder];
}

- (void)loadView
{
    self.view = [[[NSBundle mainBundle] loadNibNamed:@"ConverterView" owner:self options:NULL] lastObject];
    field1 = (UITextField *)[self.view viewWithTag:11];
    field2 = (UITextField *)[self.view viewWithTag:12];
    field1.keyboardType = UIKeyboardTypeDecimalPad;

    // Set title and add convert button
    self.title = @"Converter";
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Convert", @selector(convert:));
}

- (BOOL) shouldAutorotateToInterfaceOrientation:
    (UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow *window;
}
@end

@implementation TestBedAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UINavigationController *nav = [[UINavigationController alloc]
     initWithRootViewController:[[HelloWorldController alloc] init]];
    window.rootViewController = nav;
    [window makeKeyAndVisible];
}
@end

int main(int argc, char *argv[])
{
    @autoreleasepool {
        UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
    }
}

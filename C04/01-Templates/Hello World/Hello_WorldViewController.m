/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


#import "Hello_WorldViewController.h"

NSArray *allSubviews(UIView *aView);

// recursive descent
NSArray *allSubviews(UIView *aView)
{
	NSArray *results = [aView subviews];
	for (UIView *eachView in [aView subviews])
	{
		NSArray *theSubviews = allSubviews(eachView);
		if (theSubviews) 
            results = [results arrayByAddingObjectsFromArray:theSubviews];
	}
	return results;
}

@implementation Hello_WorldViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    field1.keyboardType = UIKeyboardTypeDecimalPad;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    BOOL isPortrait = UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]);
    UIViewController *templateController = [self.storyboard instantiateViewControllerWithIdentifier:isPortrait ? @"Portrait" : @"Landscape"];
    if (templateController)
    {
        for (UIView *eachView in allSubviews(templateController.view))
        {
            int tag = eachView.tag;
            if (tag < 10) continue;
            [self.view viewWithTag:tag].frame = eachView.frame;
        }
   }    
}

- (void) viewDidAppear:(BOOL)animated
{
    [self didRotateFromInterfaceOrientation:0];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction) convert: (id) sender
{
    float invalue = [[field1 text] floatValue];
    float outvalue = (invalue - 32.0f) * 5.0f / 9.0f;
    [field2 setText:[NSString stringWithFormat:@"%3.2f", outvalue]];
    [field1 resignFirstResponder];
}
@end

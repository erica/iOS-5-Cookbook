/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define IS_IPHONE			(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

@interface TestBedViewController : UIViewController <UIPickerViewDelegate, UIActionSheetDelegate, UIPickerViewDataSource>
@end

@implementation TestBedViewController

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 3; // three columns
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return 20; // twenty items per column
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [NSString stringWithFormat:@"%@-%d", component == 1 ? @"R" : @"L", row];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	UIPickerView *pickerView = (UIPickerView *)[actionSheet viewWithTag:101];
	self.title = [NSString stringWithFormat:@"L%d-R%d-L%d", [pickerView selectedRowInComponent:0], [pickerView selectedRowInComponent:1], [pickerView selectedRowInComponent:2]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	self.title = [NSString stringWithFormat:@"L%d-R%d-L%d", [pickerView selectedRowInComponent:0], [pickerView selectedRowInComponent:1], [pickerView selectedRowInComponent:2]];
}

- (void) action: (id) sender
{
	
	// Establish enough space for the picker
	NSString *title = @"\n\n\n\n\n\n\n\n\n\n\n\n";
	if (IS_IPHONE)
		title = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? @"\n\n\n\n\n\n\n\n\n" : @"\n\n\n\n\n\n\n\n\n\n\n\n" ;
    
	// Create the base action sheet
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Set Combo", nil];

    if (IS_IPHONE)
        [actionSheet showInView:self.view];
    else
        [actionSheet showFromBarButtonItem:sender animated:NO];
	
	// Build the picker
	UIPickerView *pickerView = [[UIPickerView alloc] init];
	pickerView.tag = 101;
	pickerView.delegate = self;
	pickerView.dataSource = self;
	pickerView.showsSelectionIndicator = YES;
    
	// If working with an iPad, adjust the frames as needed
	if (!IS_IPHONE)
	{
		pickerView.frame = CGRectMake(0.0f, 0.0f, 272.0f, 216.0f);
		CGPoint center = actionSheet.center;
		actionSheet.frame = CGRectMake(0.0f, 0.0f, 272.0f, 253.0f);
		actionSheet.center = center;
	}
	
	// Embed the picker
	[actionSheet addSubview:pickerView];
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
@end

#pragma mark -

#pragma mark Application Setup
@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
}
@end
@implementation TestBedAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{	
    [application setStatusBarHidden:YES];
    [[UINavigationBar appearance] setTintColor:COOKBOOK_PURPLE_COLOR];
    
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
    window.rootViewController = nav;
	[window makeKeyAndVisible];
    return YES;
}
@end
int main(int argc, char *argv[]) {
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
        return retVal;
    }
}
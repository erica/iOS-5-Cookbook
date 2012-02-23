/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ModalAlertDelegate.h"
#import "NSData-Base64.h"

#define IS_IPHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define PRODUCT_ID	@"com.sadun.moo.baa"
#define SANDBOX	YES

@interface TestBedViewController : UIViewController  <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    UIImageView *imageView;
    SystemSoundID moosound;
    SystemSoundID baasound;
    SystemSoundID adultsound;
    NSUInteger lastOrientation;
    BOOL subsequentSound;
    
    BOOL hasBaa;
    UIButton *purchaseButton;
    NSTimer *dismissalTimer;
    
    UIGestureRecognizer *longPressRecognizer;
}
@end

@implementation TestBedViewController
#pragma mark - Payments
- (void) restorePurchases
{
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{

}

- (void) checkReceipt: (SKPaymentTransaction *) transaction
{
    NSString *receiptData = [transaction.transactionReceipt base64Encoding];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:receiptData forKey:@"receipt-data"];
    NSData *json = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    if (!json)
    {
        NSLog(@"Error creating the JSON representation for the transaction receipt");
        return;
    }
    
    // Select target
	NSString *urlsting = SANDBOX ? @"https://sandbox.itunes.apple.com/verifyReceipt" : @"https://buy.itunes.apple.com/verifyReceipt";
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: urlsting]];
	if (!urlRequest) 
    {
        NSLog(@"Error creating the URL request");
        return;
    }
	
	[urlRequest setHTTPMethod: @"POST"];
	[urlRequest setHTTPBody:json];
	
	NSError *error;
	NSURLResponse *response;
	NSData *result = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
	
	NSString *resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    NSLog(@"Receipt Validation: %@", resultString);
}

- (void) completedPurchaseTransaction: (SKPaymentTransaction *) transaction
{
    // PERFORM THE SUCCESS ACTION THAT UNLOCKS THE FEATURE HERE
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"baa"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    hasBaa = YES;
    
    // Update GUI accordingly
    if (purchaseButton)
    {
        [purchaseButton removeFromSuperview];
        purchaseButton = nil;
    }
    
    if (longPressRecognizer)
    {
        [imageView removeGestureRecognizer:longPressRecognizer];
        longPressRecognizer = nil;
    }
    
    // Baaaaaa!
    AudioServicesPlaySystemSound(baasound);
    
    // Finish transaction
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    UIAlertView *okay = [[UIAlertView alloc] initWithTitle:@"Thank you for your purchase!" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    ModalAlertDelegate *delegate = [ModalAlertDelegate delegateWithAlert:okay];
    [delegate show];
    
    [self checkReceipt:transaction];
}

- (void) handleFailedTransaction: (SKPaymentTransaction *) transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        UIAlertView *okay = [[UIAlertView alloc] initWithTitle:@"Transaction Error. Please try again later." message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        ModalAlertDelegate *delegate = [ModalAlertDelegate delegateWithAlert:okay];
        [delegate show];
    }

    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    // Restore the GUI
    [imageView addGestureRecognizer:longPressRecognizer];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored:
                [self completedPurchaseTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self handleFailedTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:
                [self restorePurchases];
                break;
            default: break;
        }
    }
}

#pragma mark - Product Info
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: Could not contact App Store properly: %@", error.localizedFailureReason);
}

- (void)requestDidFinish:(SKRequest *)request
{
    NSLog(@"Request finished");
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	// Find a product
	SKProduct *product = [[response products] lastObject];
	if (!product)
	{
        NSLog(@"Error: Could not find matching products");
		return;
	}
	
	// Retrieve the localized price
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[numberFormatter setLocale:product.priceLocale];
	NSString *priceString = [numberFormatter stringFromNumber:product.price];

	// Show the information
    NSLog(@"About to ask user to purchase");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:product.localizedTitle message:product.localizedDescription delegate:nil cancelButtonTitle:@"No Thanks" otherButtonTitles:priceString, nil];
    ModalAlertDelegate *delegate = [ModalAlertDelegate delegateWithAlert:alert];
    BOOL answer = [delegate show];
    
    NSLog(@"User %@ buy", answer ? @"will" : @"will not");
    if (!answer)
    {
        [imageView addGestureRecognizer:longPressRecognizer];
        return;   
    }
    
    // Ready to purchase
    SKPayment *payment = [SKPayment paymentWithProduct:product]; 
    [[SKPaymentQueue defaultQueue] addPayment:payment];    
}

#pragma mark - IAP
- (void) purchaseBaa: (UIButton *) button
{
    // Tapped purchase. Get rid of timer.
    [dismissalTimer invalidate];
    dismissalTimer = nil;
    button.enabled = NO;
    [imageView removeGestureRecognizer:longPressRecognizer];
    
    AudioServicesPlaySystemSound(adultsound);
    
    [UIView animateWithDuration:0.3f animations:^() {
        button.alpha = 0.0f;       
    }];
    
    // Begin purchase process
    SKProductsRequest *productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:PRODUCT_ID]];
	productRequest.delegate = self;
	[productRequest start];
}

- (void) hidePurchaseButton: (NSTimer *) timer
{
    dismissalTimer = nil;
    [UIView animateWithDuration:0.3f animations:^(){
        purchaseButton.alpha = 0.0f;
        purchaseButton.enabled = NO;
    }];
}

- (void) revealPurchaseButton: (UIGestureRecognizer *) uigr
{
    if (dismissalTimer)
        [dismissalTimer invalidate];
    dismissalTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(hidePurchaseButton:) userInfo:nil repeats:NO];
    purchaseButton.enabled = YES;

    [UIView animateWithDuration:0.3f animations:^(){
        purchaseButton.alpha = 1.0f;
    }];
}

#pragma mark - Moo
- (void) moo
{
    // If first sound or no upgrade, always play moo
    if (!subsequentSound || !hasBaa)
    {
        AudioServicesPlaySystemSound(moosound);
        subsequentSound = YES;
        return;
    }
        
    // Upgraded audio available
    BOOL baa = ((random() % 10) == 0); // 10% chance - you have to work for it
    AudioServicesPlaySystemSound(baa ? baasound : moosound);
}

- (void) handleOrientationUpdate: (NSNotification *) notification
{
    NSUInteger orientation = [UIDevice currentDevice].orientation;
    if ((orientation == UIDeviceOrientationFaceDown) || (orientation == UIDeviceOrientationFaceUp))
    {
        if (lastOrientation == 999)
        {
            lastOrientation = orientation;
            return;
        }

        if (lastOrientation == orientation) return;
        
        lastOrientation = orientation;
        [self moo];
    }
}

#pragma mark - Setup
- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    srandom(time(0));
    lastOrientation = 999;
    hasBaa = [[NSUserDefaults standardUserDefaults] boolForKey:@"baa"];
    
    NSString *sndpath;
    
    // One Second
    sndpath = [[NSBundle mainBundle] pathForResource:@"Adult" ofType:@"wav"];
    if (sndpath)
        AudioServicesCreateSystemSoundID ((__bridge CFURLRef)[NSURL fileURLWithPath:sndpath], &adultsound);

    // Moo
    sndpath = [[NSBundle mainBundle] pathForResource:@"Moo" ofType:@"wav"];
    if (sndpath)
        AudioServicesCreateSystemSoundID ((__bridge CFURLRef)[NSURL fileURLWithPath:sndpath], &moosound);

    // Baa -- Only load if purchased
    sndpath = [[NSBundle mainBundle] pathForResource:@"Baah" ofType:@"wav"];
    if (sndpath)
        AudioServicesCreateSystemSoundID ((__bridge CFURLRef)[NSURL fileURLWithPath:sndpath], &baasound);
    
    // La la la. (Cite: Boynton. http://www.amazon.com/Moo-Baa-Sandra-Boynton/dp/067144901X )
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientationUpdate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    if (!imageView)
    {
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Moo.png"]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.userInteractionEnabled = YES;
        [self.view addSubview:imageView];
        
        if (!hasBaa)
        {
            if (!longPressRecognizer)
                longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(revealPurchaseButton:)];
            
            [imageView addGestureRecognizer:longPressRecognizer];
            
            // Create and add a purchase button
            purchaseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [purchaseButton setTitle:@"Buy a Baa!" forState:UIControlStateNormal];
            [purchaseButton addTarget:self action:@selector(purchaseBaa:) forControlEvents:UIControlEventTouchUpInside];
            purchaseButton.titleLabel.font = [UIFont fontWithName:@"Futura" size: IS_IPHONE ? 14.0f : 36.0f];
            purchaseButton.frame = CGRectMake(0.0f, 0.0f, IS_IPHONE ? 200.0f : 400.0f, IS_IPHONE ? 40.0f : 60.0f);
            purchaseButton.backgroundColor = [UIColor clearColor];
            purchaseButton.alpha = 0.0f;
            purchaseButton.enabled = NO;
            [imageView addSubview:purchaseButton];
       }        
    }

    imageView.frame = self.view.bounds;
    purchaseButton.center = CGPointMake(CGRectGetMidX(imageView.bounds), CGRectGetMidY(imageView.bounds));
}

- (void) dealloc
{
	if (moosound) AudioServicesDisposeSystemSoundID(moosound);
    if (baasound) AudioServicesDisposeSystemSoundID(baasound);
    if (adultsound) AudioServicesDisposeSystemSoundID(adultsound);
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
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	TestBedViewController *tbvc = [[TestBedViewController alloc] init];
    window.rootViewController = tbvc;
	[window makeKeyAndVisible];
    
    BOOL hasBaa = [[NSUserDefaults standardUserDefaults] boolForKey:@"baa"];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:tbvc];
    if (!hasBaa) 
        [tbvc restorePurchases];
    
    return YES;
}
@end
int main(int argc, char *argv[]) {
    @autoreleasepool {
        int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
        return retVal;
    }
}
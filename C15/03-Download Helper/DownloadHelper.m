/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.0 Edition
 BSD License, Use at your own risk
 */

#import "DownloadHelper.h"

#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)

@implementation DownloadHelper
@synthesize delegate, urlString, targetPath;
@synthesize isDownloading, bytesRead, expectedLength;

- (void) start
{
	isDownloading = NO;
    if (!urlString)
    {
        NSLog(@"URL string required but not set");
        return;
    }
	
	NSURL *url = [NSURL URLWithString:urlString];
	if (!url)
	{
		NSString *reason = [NSString stringWithFormat:@"Could not create URL from string %@", urlString];
		SAFE_PERFORM_WITH_ARG(delegate, @selector(dataDownloadFailed:), reason);
		return;
	}
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
	if (!theRequest)
	{
		NSString *reason = [NSString stringWithFormat:@"Could not create URL request from string %@", urlString];
		SAFE_PERFORM_WITH_ARG(delegate, @selector(dataDownloadFailed:), reason);
		return;
	}
	
	urlconnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (!urlconnection)
	{
		NSString *reason = [NSString stringWithFormat:@"URL connection failed for string %@", urlString];
		SAFE_PERFORM_WITH_ARG(delegate, @selector(dataDownloadFailed:), reason);
		return;
	}
	
	outputStream = [[NSOutputStream alloc] initToFileAtPath:targetPath append:YES];
	if (!outputStream)
	{
		NSString *reason = [NSString stringWithFormat:@"Could not create output stream at path %@", targetPath];
		SAFE_PERFORM_WITH_ARG(delegate, @selector(dataDownloadFailed:), reason);
		return;
	}
	[outputStream open];
	
	isDownloading = YES;
	bytesRead = 0;
	
	NSLog(@"Beginning download");
	[urlconnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void) cleanup
{
	isDownloading = NO;
    if (urlconnection)
    {
        [urlconnection cancel];
        urlconnection = nil;
    }
    
    if (outputStream)
    {
        [outputStream close];
        outputStream = nil;
    }
    
    self.urlString = nil;
	self.targetPath = nil;
}

- (void) dealloc
{
    [self cleanup];
}

- (void) cancel
{
    [self cleanup];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse
{
	// Check for bad connection
	expectedLength = [aResponse expectedContentLength];
	if (expectedLength == NSURLResponseUnknownLength)
	{
		NSString *reason = [NSString stringWithFormat:@"Invalid URL [%@]", urlString];
		SAFE_PERFORM_WITH_ARG(delegate, @selector(dataDownloadFailed:), reason);
		[connection cancel];
		[self cleanup];
		return;
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData
{
	bytesRead += theData.length;
	NSUInteger bytesLeft = theData.length;
	NSUInteger bytesWritten = 0;
	do {
		bytesWritten = [outputStream write:theData.bytes maxLength:bytesLeft];
		if (-1 == bytesWritten) break;
		bytesLeft -= bytesWritten;
	} while (bytesLeft > 0);
	if (bytesLeft) {
		NSLog(@"stream error: %@", [outputStream streamError]);
	}

	SAFE_PERFORM_WITH_ARG(delegate, @selector(downloadReceivedData), nil);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// finished downloading the data, cleaning up
	[outputStream close];
	[urlconnection unscheduleFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[self cleanup];
	
	SAFE_PERFORM_WITH_ARG(delegate, @selector(downloadFinished), nil);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	isDownloading = NO;
	NSLog(@"Error: Failed connection, %@", [error localizedFailureReason]);
	SAFE_PERFORM_WITH_ARG(delegate, @selector(dataDownloadFailed:), @"Failed Connection");
	[self cleanup];
}

+ (id) download:(NSString *) aURLString withTargetPath: (NSString *) aPath withDelegate: (id <DownloadHelperDelegate>) aDelegate
{
    if (!aURLString)
    {
        NSLog(@"Error. No URL string");
        return nil;
    }
    
    if (!aPath)
    {
        NSLog(@"Error: No target path");
        return nil;
    }
    
    DownloadHelper *helper = [[self alloc] init];
    helper.urlString = aURLString;
    helper.targetPath = aPath;
    helper.delegate = aDelegate;
    [helper start];
    
    return helper;
}
@end

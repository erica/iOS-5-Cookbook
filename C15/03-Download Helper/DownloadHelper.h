/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.0 Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

@protocol DownloadHelperDelegate <NSObject, NSURLConnectionDelegate>
@optional
- (void) downloadFinished;
- (void) downloadReceivedData;
- (void) dataDownloadFailed: (NSString *) reason;
@end

@interface DownloadHelper : NSObject 
{
	NSOutputStream *outputStream;
	NSURLConnection *urlconnection;
	
	BOOL isDownloading;
	int bytesRead;
	int expectedLength;
}
@property (strong) NSString *urlString;
@property (strong) NSString *targetPath;

@property (weak) id <DownloadHelperDelegate> delegate;

@property (readonly) BOOL isDownloading;
@property (readonly) int bytesRead;
@property (readonly) int expectedLength;

+ (id) download:(NSString *) aURLString withTargetPath: (NSString *) aPath withDelegate: (id <DownloadHelperDelegate>) aDelegate;
- (void) cancel;
@end

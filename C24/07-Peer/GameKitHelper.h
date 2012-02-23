/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@protocol GameKitHelperDataDelegate <NSObject>
@optional
- (void) connectionEstablished;
- (void) connectionLost;
- (void) sentData: (NSString *) errorMessage;
- (void) receivedData: (NSData *) data;
@end


@interface GameKitHelper : NSObject <GKPeerPickerControllerDelegate, GKSessionDelegate>
{
	BOOL isConnected;
    GKSession *session;
}

@property (weak) UIViewController <GameKitHelperDataDelegate> *dataDelegate;
@property (strong) NSString *sessionID;
@property (strong, readonly) GKSession *session;
@property (assign, readonly) BOOL isConnected;

- (void) connect;
- (void) disconnect;
- (void) sendData: (NSData *) data;

+ (id) helperWithSessionName: (NSString *) name delegate: (UIViewController <GameKitHelperDataDelegate> *) delegate;
@end

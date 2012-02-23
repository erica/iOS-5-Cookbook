
/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "GameKitHelper.h"

@implementation GameKitHelper
@synthesize dataDelegate;
@synthesize sessionID;
@synthesize session;
@synthesize isConnected;

#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

// Simple Alert Utility
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

#pragma mark Data Sharing
- (void) sendData: (NSData *) data
{
	NSError *error;
	BOOL didSend = [self.session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:&error];
	if (!didSend)
		NSLog(@"Error sending data to peers: %@", error.localizedFailureReason);
    SAFE_PERFORM_WITH_ARG(dataDelegate, @selector(sentData:), (didSend ? nil : error.localizedFailureReason));
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
    SAFE_PERFORM_WITH_ARG(dataDelegate, @selector(receivedData:), data);
}

#pragma mark Connections
- (void) connect
{
	if (!isConnected)
	{
		GKPeerPickerController *picker = [[GKPeerPickerController alloc] init];
		picker.delegate = self; 
		picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
		[picker show];
        dataDelegate.navigationItem.rightBarButtonItem = nil;
	}
}

- (void) setupConnectButton
{
    dataDelegate.navigationItem.rightBarButtonItem = BARBUTTON(@"Connect", @selector(connect));
    dataDelegate.navigationItem.rightBarButtonItem.enabled = YES;
}

// Dismiss the peer picker on cancel
- (void) peerPickerControllerDidCancel: (GKPeerPickerController *)picker
{
    [self setupConnectButton];
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession: (GKSession *) aSession{ 
	[picker dismiss];
	[session setDataReceiveHandler:self withContext:nil];
	isConnected = YES;
    SAFE_PERFORM_WITH_ARG(dataDelegate, @selector(connectionEstablished), nil);
}

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type 
{ 
	// The session ID is basically the name of the service, and is used to create the bonjour connection.
    if (!session) 
    { 
        session = [[GKSession alloc] initWithSessionID:(self.sessionID ? self.sessionID : @"Sample Session") displayName:nil sessionMode:GKSessionModePeer]; 
        session.delegate = self; 
    } 
	return session;
}

#pragma mark Session Handling
- (void) disconnect
{
	[session disconnectFromAllPeers];
	session = nil;
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
	/* STATES: GKPeerStateAvailable, = 0,  GKPeerStateUnavailable, = 1,  GKPeerStateConnected, = 2, 
	   GKPeerStateDisconnected, = 3, GKPeerStateConnecting = 4 */
	
	NSArray *states = [NSArray arrayWithObjects:@"Available", @"Unavailable", @"Connected", @"Disconnected", @"Connecting", nil];
	NSLog(@"Peer state is now %@", [states objectAtIndex:state]);
	
    if (state == GKPeerStateConnected)
    {
        dataDelegate.navigationItem.rightBarButtonItem = BARBUTTON(@"Disconnect", @selector(disconnect));
        dataDelegate.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else if (state == GKPeerStateDisconnected)
    {
        isConnected = NO;
        showAlert(@"Lost connection with peer. You are no longer connected to another device.");
        [self disconnect];
        [self setupConnectButton];
        SAFE_PERFORM_WITH_ARG(dataDelegate, @selector(connectionLost), nil);
    }
    else if (state == GKPeerStateAvailable)
    {
        dataDelegate.navigationItem.rightBarButtonItem = BARBUTTON(@"Peer Available", nil);
        dataDelegate.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else if (state == GKPeerStateUnavailable)
    {
        dataDelegate.navigationItem.rightBarButtonItem = BARBUTTON(@"Peer Unavailable", nil);
        dataDelegate.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else if (state == GKPeerStateConnecting)
    {
        dataDelegate.navigationItem.rightBarButtonItem = BARBUTTON(@"Connecting...", nil);
        dataDelegate.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

+ (id) helperWithSessionName: (NSString *) name delegate: (UIViewController <GameKitHelperDataDelegate> *) delegate
{
    GameKitHelper *helper = [[GameKitHelper alloc] init];
    helper.sessionID = name;
    helper.dataDelegate = delegate;
    [helper setupConnectButton];

    return helper;
}
@end
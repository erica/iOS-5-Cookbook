/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#include <arpa/inet.h>
#include <netdb.h>

#define BUFSIZE 8096

#define STATUS_OFFLINE	0
#define STATUS_ATTEMPT	1
#define STATUS_ONLINE	2

@interface WebHelper : NSObject 
{
	int serverStatus;
	int listenfd;
	int socketfd;
}
@property (weak)   id delegate;
@property (readonly) int chosenPort;
@property (readonly) BOOL isServing;
+ (id) serviceWithDelegate: (id) delegate;
@end

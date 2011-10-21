/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.0 Edition
 BSD License for anything not specifically marked as developed by a third party.
 Apple's code excluded.
 Use at your own risk
 */

#import <SystemConfiguration/SystemConfiguration.h>

#import <arpa/inet.h>
#import <netdb.h>
#import <net/if.h>
#import <ifaddrs.h>
#import <unistd.h>
#import <dlfcn.h>
#import <notify.h>

#import "UIDevice-Reachability.h"

@implementation UIDevice (Reachability)
SCNetworkConnectionFlags connectionFlags;
SCNetworkReachabilityRef reachability;

#pragma mark Class IP and Host Utilities 
// This IP Utilities are mostly inspired by or derived from Apple code. Thank you Apple.

+ (NSString *) stringFromAddress: (const struct sockaddr *) address
{
	if (address && address->sa_family == AF_INET) 
    {
		const struct sockaddr_in* sin = (struct sockaddr_in *) address;
		return [NSString stringWithFormat:@"%@:%d", [NSString stringWithUTF8String:inet_ntoa(sin->sin_addr)], ntohs(sin->sin_port)];
	}
	
	return nil;
}

+ (BOOL)addressFromString:(NSString *)IPAddress address:(struct sockaddr_in *)address
{
	if (!IPAddress || ![IPAddress length]) return NO;
	
	memset((char *) address, sizeof(struct sockaddr_in), 0);
	address->sin_family = AF_INET;
	address->sin_len = sizeof(struct sockaddr_in);
	
	int conversionResult = inet_aton([IPAddress UTF8String], &address->sin_addr);
	if (conversionResult == 0) 
    {
		NSAssert1(conversionResult != 1, @"Failed to convert the IP address string into a sockaddr_in: %@", IPAddress);
		return NO;
	}
	
	return YES;
}

+ (NSString *) addressFromData:(NSData *) addressData
{
    NSString *adr = nil;
	
    if (addressData != nil)
    {
		struct sockaddr_in addrIn = *(struct sockaddr_in *)[addressData bytes];
		adr = [NSString stringWithFormat: @"%s", inet_ntoa(addrIn.sin_addr)];
    }
	
    return adr;
}

+ (NSString *) portFromData:(NSData *) addressData
{
    NSString *port = nil;
	
    if (addressData != nil)
    {
		struct sockaddr_in addrIn = *(struct sockaddr_in *)[addressData bytes];
		port = [NSString stringWithFormat: @"%s", ntohs(addrIn.sin_port)];
    }
	
    return port;
}

+ (NSData *) dataFromAddress: (struct sockaddr_in) address
{
	return [NSData dataWithBytes:&address length:sizeof(struct sockaddr_in)];
}

- (NSString *) hostname
{
	char baseHostName[256]; // Thanks, Gunnar Larisch
	int success = gethostname(baseHostName, 255);
	if (success != 0) return nil;
	baseHostName[255] = '\0';
	
#if TARGET_IPHONE_SIMULATOR
 	return [NSString stringWithFormat:@"%s", baseHostName];
#else
	return [NSString stringWithFormat:@"%s.local", baseHostName];
#endif
}

- (NSString *) getIPAddressForHost: (NSString *) theHost
{
	struct hostent *host = gethostbyname([theHost UTF8String]);
    if (!host) {herror("resolv"); return NULL; }
	struct in_addr **list = (struct in_addr **)host->h_addr_list;
	NSString *addressString = [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];
	return addressString;
}

- (NSString *) localIPAddress
{
	struct hostent *host = gethostbyname([[self hostname] UTF8String]);
    if (!host) {herror("resolv"); return nil;}
    struct in_addr **list = (struct in_addr **)host->h_addr_list;
	return [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];
}

// Matt Brown's get WiFi IP addy solution
// Author gave permission to use in Cookbook under cookbook license
// http://mattbsoftware.blogspot.com/2009/04/how-to-get-ip-address-of-iphone-os-v221.html

// iPhone hotspot updates courtesy of Johannes Rudolph

- (NSString *) localWiFiIPAddress
{
	BOOL success;
	struct ifaddrs * addrs;
	const struct ifaddrs * cursor;
	
	success = getifaddrs(&addrs) == 0;
	if (success) {
		cursor = addrs;
		while (cursor != NULL) {
            
            // the second test keeps from picking up the loopback address
			if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0) 
			{
				NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];

                /*
                 // Uncomment for debug
                 NSLog(@"Interface name: %@, inet: %d, loopback: %d, address: %@", 
                 name, 
                 cursor->ifa_addr->sa_family == AF_INET, 
                 (cursor->ifa_flags & IFF_LOOPBACK) == 0, 
                 [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)]);
                 */                

                // Wi-Fi adapter or iPhone Personal Hotspot bridge adapter
				if ([name isEqualToString:@"en0"] || 
                    [name isEqualToString:@"bridge0"])
					return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
			}
			cursor = cursor->ifa_next;
		}
		freeifaddrs(addrs);
	}
	return nil;
}


- (NSArray *) localWiFiIPAddresses
{
	BOOL success;
	struct ifaddrs * addrs;
	const struct ifaddrs * cursor;
	
	NSMutableArray *array = [NSMutableArray array];
	
	success = getifaddrs(&addrs) == 0;
	if (success) {
		cursor = addrs;
		while (cursor != NULL) {
            
			// the second test keeps from picking up the loopback address
			if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0) 
			{
				NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                
                // Wi-Fi adapter or iPhone Personal Hotspot bridge adapter
				if ([name hasPrefix:@"en"] || [name hasPrefix:@"bridge"])
					[array addObject:[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)]];
			}
			cursor = cursor->ifa_next;
		}
		freeifaddrs(addrs);
	}
	
	if (array.count) return array;
	
	return nil;
}

- (NSString *) whatismyipdotcom
{
	NSError *error;
    NSURL *ipURL = [NSURL URLWithString:@"http://automation.whatismyip.com/n09230945.asp"];
    NSString *ip = [NSString stringWithContentsOfURL:ipURL encoding:1 error:&error];
	return ip ? ip : [error localizedDescription];
}

- (BOOL) hostAvailable: (NSString *) theHost
{
	
    NSString *addressString = [self getIPAddressForHost:theHost];
    if (!addressString)
    {
        NSLog(@"Error recovering IP address from host name\n");
        return NO;
    }
	
    struct sockaddr_in address;
    BOOL gotAddress = [UIDevice addressFromString:addressString address:&address];
	
    if (!gotAddress)
    {
		NSLog(@"Error recovering sockaddr address from %@", addressString);
        return NO;
    }
	
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&address);
    SCNetworkReachabilityFlags flags;
	
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
	
    if (!didRetrieveFlags)
    {
        NSLog(@"Error. Could not recover network reachability flags");
        return NO;
    }
	
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    return isReachable ? YES : NO;;
}

#pragma mark Checking Connections
- (void) pingReachabilityInternal
{
	if (!reachability)
	{
		BOOL ignoresAdHocWiFi = NO;
		struct sockaddr_in ipAddress;
		bzero(&ipAddress, sizeof(ipAddress));
		ipAddress.sin_len = sizeof(ipAddress);
		ipAddress.sin_family = AF_INET;
		ipAddress.sin_addr.s_addr = htonl(ignoresAdHocWiFi ? INADDR_ANY : IN_LINKLOCALNETNUM);

		/* Can also create zero addy
		 struct sockaddr_in zeroAddress;
		 bzero(&zeroAddress, sizeof(zeroAddress));
		 zeroAddress.sin_len = sizeof(zeroAddress);
		 zeroAddress.sin_family = AF_INET; */
		
		reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (struct sockaddr *)&ipAddress);
		CFRetain(reachability);
	}
	
	// Recover reachability flags
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(reachability, &connectionFlags);
	if (!didRetrieveFlags) printf("Error. Could not recover network reachability flags\n");
}

- (BOOL) networkAvailable
{
	[self pingReachabilityInternal];
	BOOL isReachable = ((connectionFlags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((connectionFlags & kSCNetworkFlagsConnectionRequired) != 0);
    return (isReachable && !needsConnection) ? YES : NO;
}

// Thanks Johannes Rudolph
- (BOOL) activePersonalHotspot
{
    // Personal hotspot is fixed to 172.20.10
    NSString* localWifiAddress = [self localWiFiIPAddress];
    return (localWifiAddress != nil && [localWifiAddress hasPrefix:@"172.20.10"]);
}


- (BOOL) activeWWAN
{
	if (![self networkAvailable]) return NO;
	return ((connectionFlags & kSCNetworkReachabilityFlagsIsWWAN) != 0);
}

- (BOOL) activeWLAN
{
	return ([[UIDevice currentDevice] localWiFiIPAddress] != nil);
}

#pragma mark WiFi Check and Alert
- (void) privateShowAlert: (id) formatstring,...
{
	va_list arglist;
	if (!formatstring) return;
	va_start(arglist, formatstring);
	id outstring = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);
	
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:outstring message:nil delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil];
	[av show];
}

- (BOOL) performWiFiCheck
{
	if (![self networkAvailable] || ![self activeWLAN])
	{
		[self performSelector:@selector(privateShowAlert:) withObject:@"This application requires WiFi. Please enable WiFi in Settings and run this application again." afterDelay:0.5f];
		return NO;
	}
	return YES;
}
@end
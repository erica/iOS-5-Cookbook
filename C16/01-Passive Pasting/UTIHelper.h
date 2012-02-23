/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

NSString *uuid();

NSString *preferredExtensionForUTI(NSString *aUTI);
NSString *preferredMimeTypeForUTI(NSString *aUTI);
NSString *preferredUTIForExtension(NSString *ext);
NSString *preferredUTIForMIMEType(NSString *mime);

NSArray *allExtensions(NSString *aUTI);
NSArray *allMIMETypes(NSString *aUTI);

NSDictionary *utiDictionary(NSString *aUTI);
NSArray *conformanceArray(NSString *aUTI);

// This does not work as promised. Convert to UTI
// and use conformanceArray instead.
NSArray *allUTIsForExtension(NSString *ext);

BOOL pathPointsToLikelyUTIMatch(NSString *path, CFStringRef theUTI);

// You can add any number of these as desired.
BOOL pathPointsToLikelyImage(NSString *path);
BOOL pathPointsToLikelyAudio(NSString *path);
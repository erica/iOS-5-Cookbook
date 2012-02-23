/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "UTIHelper.h"

NSString *uuid()
{
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	NSString *uuidString =  (__bridge_transfer NSString *)CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	return uuidString;
}

NSString *preferredExtensionForUTI(NSString *aUTI)
{
    CFStringRef theUTI = (__bridge CFStringRef) aUTI;
    CFStringRef results = UTTypeCopyPreferredTagWithClass(theUTI, kUTTagClassFilenameExtension);
    return (__bridge_transfer NSString *)results;
}

NSString *preferredMimeTypeForUTI(NSString *aUTI)
{
    CFStringRef theUTI = (__bridge CFStringRef) aUTI;
    CFStringRef results = UTTypeCopyPreferredTagWithClass(theUTI, kUTTagClassMIMEType);
    return (__bridge_transfer NSString *)results;
}


NSString *preferredUTIForExtension(NSString *ext)
{
    // Request the UTI via the file extension 
    NSString *theUTI = (__bridge_transfer NSString *) UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef) ext, NULL);
    return theUTI;
}

NSString *preferredUTIForMIMEType(NSString *mime)
{
    // Request the UTI via the file extension 
    NSString *theUTI = (__bridge_transfer NSString *) UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef) mime, NULL);
    return theUTI;
}

NSDictionary *utiDictionary(NSString *aUTI)
{
    NSDictionary *dictionary = (__bridge_transfer NSDictionary *)UTTypeCopyDeclaration((__bridge CFStringRef) aUTI);
    return dictionary;
}

NSArray *uniqueArray(NSArray *anArray)
{
    NSMutableArray *copiedArray = [NSMutableArray arrayWithArray:anArray];
    for (id object in anArray)
    {
        [copiedArray removeObjectIdenticalTo:object];
        [copiedArray addObject:object];
    }
    
    return copiedArray;
}

NSArray *conformanceArray(NSString *aUTI)
{
    NSMutableArray *results = [NSMutableArray arrayWithObject:aUTI];
    NSDictionary *dictionary = utiDictionary(aUTI);
    id conforms = [dictionary objectForKey:(__bridge NSString *)kUTTypeConformsToKey];
    
    // No conformance
    if (!conforms) return results;
    
    // Single conformance
    if ([conforms isKindOfClass:[NSString class]])
    {
        [results addObjectsFromArray:conformanceArray(conforms)];
        return uniqueArray(results);
    }
    
    // Iterate through multiple conformance
    if ([conforms isKindOfClass:[NSArray class]])
    {
        for (NSString *eachUTI in (NSArray *) conforms)
            [results addObjectsFromArray:conformanceArray(eachUTI)];
        return uniqueArray(results);
    }
    
    // Just return the one-item array
    return results;
}

NSArray *allExtensions(NSString *aUTI)
{
    NSMutableArray *results = [NSMutableArray array];
    NSArray *conformance = conformanceArray(aUTI);
    for (NSString *eachUTI in conformance)
    {
        NSDictionary *dictionary = utiDictionary(eachUTI);
        NSDictionary *extensions = [dictionary objectForKey:(__bridge NSString *)kUTTypeTagSpecificationKey];
        id fileTypes = [extensions objectForKey:(__bridge NSString *)kUTTagClassFilenameExtension];
        
        if ([fileTypes isKindOfClass:[NSArray class]])
            [results addObjectsFromArray:(NSArray *) fileTypes];
        else if ([fileTypes isKindOfClass:[NSString class]])
            [results addObject:(NSString *) fileTypes];
    }
    
    return uniqueArray(results);
}

NSArray *allMIMETypes(NSString *aUTI)
{
    NSMutableArray *results = [NSMutableArray array];
    NSArray *conformance = conformanceArray(aUTI);
    for (NSString *eachUTI in conformance)
    {
        NSDictionary *dictionary = utiDictionary(eachUTI);
        NSDictionary *extensions = [dictionary objectForKey:(__bridge NSString *)kUTTypeTagSpecificationKey];
        id fileTypes = [extensions objectForKey:(__bridge NSString *)kUTTagClassMIMEType];
        
        if ([fileTypes isKindOfClass:[NSArray class]])
            [results addObjectsFromArray:(NSArray *) fileTypes];
        else if ([fileTypes isKindOfClass:[NSString class]])
            [results addObject:(NSString *) fileTypes];
    }
    
    return uniqueArray(results);
}

NSArray *allUTIsForExtension(NSString *ext)
{
	NSArray *array = (__bridge_transfer NSArray *) UTTypeCreateAllIdentifiersForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef) ext, NULL);
	return array;
}


BOOL pathPointsToLikelyUTIMatch(NSString *path, CFStringRef theUTI)
{
	NSString *extension = path.pathExtension;
	NSString *preferredUTI = preferredUTIForExtension(extension);
	return (UTTypeConformsTo((__bridge CFStringRef) preferredUTI, theUTI));
}

BOOL pathPointsToLikelyImage(NSString *path)
{
    return pathPointsToLikelyUTIMatch(path, CFSTR("public.image"));
}

BOOL pathPointsToLikelyAudio(NSString *path)
{
    return pathPointsToLikelyUTIMatch(path, CFSTR("public.audio"));
}


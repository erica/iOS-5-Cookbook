/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "CloudHelper.h"

#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)

@implementation CloudHelper
@synthesize delegate;

#pragma mark initialization
+ (BOOL) setupUbiquityDocumentsFolderForContainer: (NSString *) container
{
    NSError *error;
    NSURL *targetURL = [self ubiquityDocumentsURLForContainer:container];
    
    // Create the ubiquity documents folder if needed
    if (![[NSFileManager defaultManager] fileExistsAtPath:targetURL.path])
    {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:targetURL.path withIntermediateDirectories:YES attributes:nil error:&error])
        {
            NSLog(@"Error creating ubiquitous Documents folder. %@", error.localizedFailureReason);
            return NO;
        }
    }
    return YES;
}

+ (BOOL) setupUbiquityDocumentsFolder
{
    return [self setupUbiquityDocumentsFolderForContainer:nil];
}

#pragma mark - Utility
+ (NSString *)applicationIdentifier
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

+ (NSString *) appName
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}

+ (NSString *) teamPrefix
{
    NSURL *ubiquity = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    if (!ubiquity) return nil;
    NSArray *elements = [[ubiquity.path lastPathComponent] componentsSeparatedByString:@"~"];
    if (!elements.count) return nil;
    return [elements objectAtIndex:0];
}

+ (NSString *) containerize: (NSString *) anIdentifier
{
    NSString *prefix = [self teamPrefix];
    if (!prefix) return nil;
    return [NSString stringWithFormat:@"%@.%@", prefix, anIdentifier];
}

+ (NSString *) documentState: (int) state
{
    if (!state) return @"Document state is normal";
    
    NSMutableString *string = [NSMutableString string];
    if ((state & UIDocumentStateClosed) != 0) 
        [string appendString:@"Document is closed\n"];
    if ((state & UIDocumentStateInConflict) != 0) 
        [string appendString:@"Document is in conflict"];
    if ((state & UIDocumentStateSavingError) != 0) 
        [string appendString:@"Document is experiencing saving error"];
    if ((state & UIDocumentStateEditingDisabled) != 0) 
        [string appendString:@"Document editing is disbled" ];
    
    return string;    
}

#pragma mark - Key Paths

#pragma mark Local Documents
+ (NSString *) localDocumentsPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (NSURL *) localDocumentsURL
{
    return [NSURL fileURLWithPath:[self localDocumentsPath]];
}

#pragma mark Ubiquity Data
+ (NSURL *) ubiquityDataURLForContainer: (NSString *) container
{
    return [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:container];
}

+ (NSString *) ubiquityDataPathForContainer: (NSString *) container
{
    return [self ubiquityDataURLForContainer:container].path;
}

+ (NSURL *) ubiquityDataURL
{
    return [self ubiquityDataURLForContainer:nil];
}

+ (NSString *) ubiquityDataPath
{
    return [self ubiquityDataURL].path;
}

#pragma mark Ubiquity Documents
+ (NSURL *) ubiquityDocumentsURLForContainer: (NSString *) container
{
    return [[self ubiquityDataURLForContainer:container] URLByAppendingPathComponent:@"Documents"];
}

+ (NSString *) ubiquityDocumentsPathForContainer: (NSString *) container
{
    return [self ubiquityDocumentsURLForContainer:container].path;
}

+ (NSURL *) ubiquityDocumentsURL
{
    return [[self ubiquityDataURL] URLByAppendingPathComponent:@"Documents"];
}

+ (NSString *) ubiquityDocumentsPath
{
    return [self ubiquityDocumentsURL].path;
}

#pragma mark - File URLs
+ (NSURL *) localFileURL: (NSString *) filename
{
    if (!filename) return nil;
    NSURL *fileURL = [[self localDocumentsURL] URLByAppendingPathComponent:filename];
    return fileURL;
}

+ (NSURL *) ubiquityDataFileURL: (NSString *) filename forContainer: (NSString *) container
{
    if (!filename) return nil;
    NSURL *fileURL = [[self ubiquityDataURLForContainer:container] URLByAppendingPathComponent:filename];
    return fileURL;
}

+ (NSURL *) ubiquityDataFileURL: (NSString *) filename
{
    return [self ubiquityDataFileURL:filename forContainer:nil];
}

+ (NSURL *) ubiquityDocumentsFileURL: (NSString *) filename forContainer: (NSString *) container
{
    if (!filename) return nil;
    NSURL *fileURL = [[self ubiquityDocumentsURLForContainer:container] URLByAppendingPathComponent:filename];
    return fileURL;
}

+ (NSURL *) ubiquityDocumentsFileURL: (NSString *) filename
{
    return [self ubiquityDocumentsFileURL:filename forContainer:nil];
}

#pragma mark - Testing Files
+ (BOOL) isLocal: (NSString *) filename
{
    if (!filename) return NO;
    NSURL *targetURL = [self localFileURL:filename];
    if (!targetURL) return NO;
    return [[NSFileManager defaultManager] fileExistsAtPath:targetURL.path];
}

+ (BOOL) isUbiquitousData: (NSString *) filename forContainer: (NSString *) container
{
    if (!filename) return NO;
    NSURL *targetURL = [self ubiquityDataFileURL:filename forContainer:container];
    if (!targetURL) return NO;
    return [[NSFileManager defaultManager] fileExistsAtPath:targetURL.path];
}

+ (BOOL) isUbiquitousData: (NSString *) filename
{
    return [self isUbiquitousData:filename forContainer:nil];
}

+ (BOOL) isUbiquitousDocument: (NSString *) filename forContainer: (NSString *) container
{
    if (!filename) return NO;
    NSURL *targetURL = [self ubiquityDocumentsFileURL:filename forContainer:container];
    if (!targetURL) return NO;
    return [[NSFileManager defaultManager] fileExistsAtPath:targetURL.path];
}

+ (BOOL) isUbiquitousDocument: (NSString *) filename
{
    return [self isUbiquitousDocument:filename forContainer:nil];
}

+ (NSURL *) fileURL: (NSString *) filename forContainer:(NSString *)container
{
    if ([self isLocal:filename])
        return [self localFileURL:filename];
    if ([self isUbiquitousDocument:filename forContainer:container])
        return [self ubiquityDocumentsFileURL:filename forContainer:container];
    if ([self isUbiquitousData:filename forContainer:container])
        return [self ubiquityDataFileURL:filename forContainer:container];
    return nil;
}

+ (NSURL *) fileURL: (NSString *) filename
{
    return [self fileURL:filename forContainer:nil];
}

#pragma mark - Moving between Documents
+ (BOOL) setUbiquitous:(BOOL)yorn for:(NSString *)filename forContainer:(NSString *)container
{
    if (!filename) return NO;
    
    NSError *error;
    NSURL *localURL = [self localFileURL:filename];
    NSURL *ubiquityURL = [self ubiquityDocumentsFileURL:filename forContainer:container];
    
    BOOL localFound = [self isLocal:filename];
    BOOL ubiquityFound = [self isUbiquitousDocument:filename forContainer:container];
    
    // Check file not found
    if (!localFound && !ubiquityFound) return NO;
    
    // Check the two "nothing to be done" cases
    if (!yorn && localFound) return YES;
    if (yorn && ubiquityFound) return YES;
    
    // ubiquitous to local
    if (!yorn)
    {
        // Move file away from cloud
        if (![[NSFileManager defaultManager] 
              setUbiquitous:NO
              itemAtURL:ubiquityURL
              destinationURL:localURL 
              error:&error])
        {
            NSLog(@"Error removing %@ from %@ cloud storage: %@", filename, container, error.localizedFailureReason);
            return NO;
        }
        
        return YES;
    }
    
    // local to ubiquitous
    if (![[NSFileManager defaultManager] 
          setUbiquitous:YES
          itemAtURL:localURL
          destinationURL:ubiquityURL
          error:&error])
    {
        NSLog(@"Error moving %@ to %@ cloud storage: %@", filename, container, error.localizedFailureReason);
        return NO;
    }
    
    return YES;
}

+ (BOOL) setUbiquitous:(BOOL)yorn for:(NSString *)filename
{
    return [self setUbiquitous:yorn for:filename forContainer:nil];
}

#pragma mark - Deletion
+ (BOOL) deleteLocal: (NSString *) filename
{
    NSURL *targetURL = [self localFileURL:filename];
    if (![[NSFileManager defaultManager] fileExistsAtPath:targetURL.path])
    {
        NSLog(@"Could not delete. Local file not found: %@", filename);
        return NO;
    }
    
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtURL:targetURL error:&error];
    if (!success)
        NSLog(@"Error removing file %@: %@", filename, error.localizedFailureReason);
    
    return success;
}

+ (BOOL) deleteUbiquitousDocument:(NSString *)filename forContainer:(NSString *)container
{
    NSURL *targetURL = [self ubiquityDocumentsFileURL:filename forContainer:container];
    if (![[NSFileManager defaultManager] fileExistsAtPath:targetURL.path])
    {
        NSLog(@"Could not delete. Ubiquitous file not found: %@", filename);
        return NO;
    }
    
    // Remove from ubiquity and then delete
    BOOL success = [self setUbiquitous:NO for:filename forContainer:container];    
    if (success) 
        return [self deleteLocal:filename];    
    return NO;
}

+ (BOOL) deleteUbiquitousData:(NSString *)filename forContainer:(NSString *)container
{
    NSError *error;
    BOOL success;
    
    NSURL *targetURL = [self ubiquityDataFileURL:filename forContainer:container];
    success = [[NSFileManager defaultManager] fileExistsAtPath:targetURL.path];
    if (!success)
    {
        NSLog(@"Could not delete. Ubiquitous file not found: %@", filename);
        return NO;
    }
    
    // DELETION HERE
    success = [[NSFileManager defaultManager] removeItemAtURL:targetURL error:&error];
    if (!success)
    {
        NSLog(@"Could not remove item at path: %@", error.localizedFailureReason);
        return NO;
    }
    
    return YES;
}

+ (BOOL) deleteDocument: (NSString *) filename forContainer:(NSString *)container
{
    // If local, delete it.
    if ([self isLocal:filename]) 
        return [self deleteLocal:filename];
    return [self deleteUbiquitousDocument:filename forContainer:container];
}

+ (BOOL) deleteUbiquitousDocument:(NSString *)filename
{
    return [self deleteUbiquitousDocument:filename forContainer:nil];
}

+ (BOOL) deleteUbiquitousData:(NSString *)filename
{
    return [self deleteUbiquitousData:filename forContainer:nil];
}

+ (BOOL) deleteDocument: (NSString *) filename
{
    return [self deleteDocument:filename forContainer:nil];
}

#pragma mark Dates
+ (NSDate *) modificationDateForURL:(NSURL *) targetURL
{
    if (!targetURL) return nil;
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:targetURL.path error:nil];
    if (!attributes) return nil;
    
    return [attributes fileModificationDate];
}

+ (NSDate *) modificationDateForFile: (NSString *) filename
{
    if (!filename) return nil;
    return [self modificationDateForURL:[self fileURL:filename]];
}

+ (NSTimeInterval) timeIntervalSinceModification: (NSString *) filename
{
    return [[NSDate date] timeIntervalSinceDate:[self modificationDateForFile:filename]];
}

#pragma mark - Contents of Folders
+ (NSArray *) contentsOfLocalDocumentsFolder
{
    NSURL *targetURL = [self localDocumentsURL];
    if (!targetURL) return nil;
    
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:targetURL.path error:nil];
    return array;
}

+ (NSArray *) contentsOfUbiquityDataFolderForContainer: (NSString *) container
{
    NSURL *targetURL = [self ubiquityDataURLForContainer:container];
    if (!targetURL) return nil;
    
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:targetURL.path error:nil];
    return array;
}

+ (NSArray *) contentsOfUbiquityDocumentsFolderForContainer: (NSString *) container
{
    NSURL *targetURL = [self ubiquityDocumentsURLForContainer:container];
    if (!targetURL) return nil;

    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:targetURL.path error:nil];
    return array;
}

+ (NSSet *) documentFolderFilesInContainer: (NSString *) container
{
    NSSet *localSet = [NSSet setWithArray:[self contentsOfLocalDocumentsFolder]];
    NSArray *ubiquitousArray = [self contentsOfUbiquityDocumentsFolderForContainer:container];
    localSet = [localSet setByAddingObjectsFromArray:ubiquitousArray];
    return localSet;
}

+ (NSArray *) contentsOfUbiquityDataFolder
{
    return [self contentsOfUbiquityDataFolderForContainer:nil];
}

+ (NSArray *) contentsOfUbiquityDocumentsFolder
{
    return [self contentsOfUbiquityDocumentsFolderForContainer:nil];
}

+ (NSSet *) documentFolderFiles
{
    return [self documentFolderFilesInContainer:nil];
}

#pragma mark - Eviction
+ (BOOL) evictFile: (NSString *) filename forContainer: (NSString *) container
{
    if (!filename) return NO;
    
    NSURL *targetURL = [self ubiquityDocumentsFileURL:filename forContainer:container];
    BOOL targetExists = [[NSFileManager defaultManager] fileExistsAtPath:targetURL.path];
    if (!targetExists) return NO;
    
    NSError *error;
    if (![[NSFileManager defaultManager] evictUbiquitousItemAtURL:targetURL error:&error])
    {
        NSLog(@"Error evicting current copy of %@.: %@", filename, error.localizedFailureReason);
        return NO;
    }
    
    return YES;
}

+ (BOOL) evictFile: (NSString *) filename
{
    return [self evictFile:filename forContainer:nil];
}

+ (BOOL) forceDownload: (NSString *) filename forContainer: (NSString*) container
{
    if (!filename) return NO;
    NSURL *targetURL = [self ubiquityDocumentsFileURL:filename forContainer:container];
    if (!targetURL) return NO;
    
    NSError *error;
    if (![self evictFile:filename forContainer:container]) return NO;
    if (![[NSFileManager defaultManager] 
          startDownloadingUbiquitousItemAtURL:targetURL error:&error])
    {
        NSLog(@"Error starting download of %@: %@", filename, 
              error.localizedFailureReason);
        return NO;
    }
    
    return YES;
}

+ (BOOL) forceDownload: (NSString *) filename
{
    return [self forceDownload:filename forContainer:nil];
}

#pragma mark - Debugging
+ (void) scan: (NSString *) path indent: (int) indentation
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    // Check for file existence
    BOOL isDir;
    if (![manager fileExistsAtPath:path isDirectory:&isDir]) return;

    // Indent and show name
    for (int i = 0; i < indentation; i++)
        printf("    ");
    
    // Retrieve mod date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterMediumStyle;
    NSDate *modDate = [[manager attributesOfItemAtPath:path error:nil] fileModificationDate];
    NSString *modDateString = [formatter stringFromDate:modDate];
    
    printf("%s [%s]\n", path.lastPathComponent.UTF8String, modDateString.UTF8String);
    if (!isDir) return;
    
    // Recurse for folders
    NSArray *files = [manager contentsOfDirectoryAtPath:path error:nil];
    for (NSString *file in files)
    {
        NSString *newPath = [path stringByAppendingPathComponent:file];
        [self scan:newPath indent:indentation + 1];
    }
}

+ (void) deepScanContainer: (NSString *) container
{
    NSLog(@"Deep scan of container: %@", container ? : [self applicationIdentifier]);
    [self scan:[self ubiquityDataPathForContainer:container] indent:0];
}

+ (void) timeScan: (NSString *) path
{
    NSFileManager *manager = [NSFileManager defaultManager];

    // Check for file existence
    BOOL isDir;
    if (![manager fileExistsAtPath:path isDirectory:&isDir]) return;
    
    // Retrieve mod date
    NSDate *modDate = [[manager attributesOfItemAtPath:path error:nil] fileModificationDate];
    
    // Within last 30 seconds
    if (([[NSDate date] timeIntervalSinceDate:modDate] < 30.0f))
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterMediumStyle;
        NSString *modDateString = [formatter stringFromDate:modDate];
        printf("%s [%s]\n", path.UTF8String, modDateString.UTF8String);
    }
     
    if (!isDir) return;
    
    // Recurse for folders
    NSArray *files = [manager contentsOfDirectoryAtPath:path error:nil];
    for (NSString *file in files)
    {
        NSString *newPath = [path stringByAppendingPathComponent:file];
        [self timeScan:newPath];
    }
}

+ (void) newlyModifiedInContainer: (NSString *) container
{
    NSLog(@"Newly modified in container: %@", container ? : [self applicationIdentifier]);
    [self timeScan:[self ubiquityDataPathForContainer:container]];
}


#pragma mark - Monitor
- (void) startMonitoringUbiquitousDocumentsFolder
{
    // Remove any existing query
    if (query) [query stopQuery];
    
    query = [[NSMetadataQuery alloc] init];
    query.predicate = [NSPredicate predicateWithFormat:@"NSMetadataItemFSNameKey == '*'"];
    query.searchScopes = [NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope];
    
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:NSMetadataQueryDidStartGatheringNotification 
     object:nil queue:[NSOperationQueue mainQueue]
     usingBlock:^(NSNotification __strong *notification) 
     {
         [query disableUpdates];
         NSMutableArray *array = [NSMutableArray array];
         for (NSMetadataItem *item in query.results)
             [array addObject:[item valueForAttribute:NSMetadataItemFSNameKey]];
         [query enableUpdates];
         
         if (delegate) SAFE_PERFORM_WITH_ARG(delegate, @selector(ubiquityDocumentsFolderContentsHaveChanged:), array);
     }];
    
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:NSMetadataQueryDidUpdateNotification 
     object:nil queue:[NSOperationQueue mainQueue]
     usingBlock:^(NSNotification __strong *notification) 
     {
         [query disableUpdates];
         NSMutableArray *array = [NSMutableArray array];
         for (NSMetadataItem *item in query.results)
             [array addObject:[item valueForAttribute:NSMetadataItemFSNameKey]];
         [query enableUpdates];

         if (delegate) SAFE_PERFORM_WITH_ARG(delegate, @selector(ubiquityDocumentsFolderContentsHaveChanged:), array);
     }];
    
    [query startQuery];
}

- (void) stopMonitoringUbiquitousDocumentsFolder
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidUpdateNotification object:nil];

    [query stopQuery];
    query = nil;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

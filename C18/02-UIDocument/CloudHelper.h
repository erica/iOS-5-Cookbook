/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


#import <Foundation/Foundation.h>

@interface CloudHelper : NSObject
{
    @private
    NSMetadataQuery *query;
}
@property (assign) id delegate;

// Setup
+ (BOOL) setupUbiquityDocumentsFolderForContainer: (NSString *) container;
+ (BOOL) setupUbiquityDocumentsFolder;

// Utility
+ (NSString *) applicationIdentifier;
+ (NSString *) appName;
+ (NSString *) teamPrefix;
+ (NSString *) containerize: (NSString *) anIdentifier;
+ (NSString *) documentState: (int) state;

// Key Paths and URLs
+ (NSString *) localDocumentsPath;
+ (NSURL *) localDocumentsURL;

+ (NSString *) ubiquityDataPathForContainer: (NSString *) container;
+ (NSURL *) ubiquityDataURLForContainer: (NSString *) container;
+ (NSString *) ubiquityDataPath;
+ (NSURL *) ubiquityDataURL;

+ (NSString *) ubiquityDocumentsPathForContainer: (NSString *) container;
+ (NSURL *) ubiquityDocumentsURLForContainer: (NSString *) container;
+ (NSString *) ubiquityDocumentsPath;
+ (NSURL *) ubiquityDocumentsURL;

// Files URLs
+ (NSURL *) localFileURL: (NSString *) filename;
+ (NSURL *) ubiquityDataFileURL: (NSString *) filename forContainer: (NSString *) container;
+ (NSURL *) ubiquityDocumentsFileURL: (NSString *) filename forContainer: (NSString *) container;
+ (NSURL *) ubiquityDataFileURL: (NSString *) filename;
+ (NSURL *) ubiquityDocumentsFileURL: (NSString *) filename;

// Testing Files
+ (BOOL) isLocal: (NSString *) filename;
+ (BOOL) isUbiquitousData: (NSString *) filename forContainer: (NSString *) container;
+ (BOOL) isUbiquitousDocument: (NSString *) filename forContainer: (NSString *) container;
+ (BOOL) isUbiquitousData: (NSString *) filename;
+ (BOOL) isUbiquitousDocument: (NSString *) filename;
+ (NSURL *) fileURL: (NSString *) filename forContainer: (NSString *) container;
+ (NSURL *) fileURL: (NSString *) filename;

// Moving between Documents
+ (BOOL) setUbiquitous:(BOOL)yorn for:(NSString *)filename;
+ (BOOL) setUbiquitous:(BOOL)yorn for:(NSString *)filename forContainer: (NSString *) container;

// Deleting Files
+ (BOOL) deleteLocal: (NSString *) filename;
+ (BOOL) deleteUbiquitousData:(NSString *)filename forContainer: (NSString *) container;
+ (BOOL) deleteUbiquitousDocument:(NSString *)filename forContainer: (NSString *) container;
+ (BOOL) deleteDocument: (NSString *) filename forContainer: (NSString *) container;
+ (BOOL) deleteUbiquitousData:(NSString *)filename;
+ (BOOL) deleteUbiquitousDocument:(NSString *)filename;
+ (BOOL) deleteDocument: (NSString *) filename;

// Dates
+ (NSDate *) modificationDateForURL:(NSURL *) targetURL;
+ (NSDate *) modificationDateForFile: (NSString *) filename;
+ (NSTimeInterval) timeIntervalSinceModification: (NSString *) filename;


// Contents of Folders
+ (NSArray *) contentsOfLocalDocumentsFolder;
+ (NSArray *) contentsOfUbiquityDataFolderForContainer: (NSString *) container;
+ (NSArray *) contentsOfUbiquityDocumentsFolderForContainer: (NSString *) container;
+ (NSSet *) documentFolderFilesInContainer: (NSString *) container;
+ (NSArray *) contentsOfUbiquityDataFolder;
+ (NSArray *) contentsOfUbiquityDocumentsFolder;
+ (NSSet *) documentFolderFiles;

// Eviction
+ (BOOL) evictFile: (NSString *) filename forContainer: (NSString *) container;
+ (BOOL) forceDownload: (NSString *) filename forContainer: (NSString *) container;
+ (BOOL) evictFile: (NSString *) filename;
+ (BOOL) forceDownload: (NSString *) filename;


// Debugging
+ (void) deepScanContainer: (NSString *) container;
+ (void) newlyModifiedInContainer: (NSString *) container;

// Monitoring
- (void) startMonitoringUbiquitousDocumentsFolder;
- (void) stopMonitoringUbiquitousDocumentsFolder;
@end

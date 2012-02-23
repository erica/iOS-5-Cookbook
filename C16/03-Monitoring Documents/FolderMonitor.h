/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

/*
 
 This code should work in some future iOS update but does not do so at this time.
 
 */

@interface FolderMonitor : NSObject
{
    NSMetadataQuery *query;
}
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSString *folderPath;
+ (id) monitor:(NSString *) path withDelegate: (id) delegate;
@end


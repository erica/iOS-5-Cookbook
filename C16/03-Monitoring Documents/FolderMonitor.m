/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


#import "FolderMonitor.h"

#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)

@implementation FolderMonitor
@synthesize delegate, folderPath;
- (void)queryUpdated:(NSNotification *)notification
{
    if (notification.object != query)
    {
        NSLog(@"Error. Mismatch between notification and query. Bailing.");
        return;
    }

    SAFE_PERFORM_WITH_ARG(delegate, @selector(contentsChanged:), folderPath);
}

- (void) startMonitoring
{
    // No path, no query
    if (!folderPath) return;
    NSLog(@"About to monitor %@", folderPath);
    
    // Remove any existing query
    if (query) [query stopQuery];
    
    query = [[NSMetadataQuery alloc] init];
    
    // Only search in the specified folder
    query.searchScopes = [NSArray arrayWithObject:folderPath];    
    query.predicate = [NSPredicate predicateWithFormat:@"NSMetadataItemFSNameKey == '*'"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryUpdated:) name:NSMetadataQueryDidUpdateNotification object:query];

    [query startQuery];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [query stopQuery];
    query = nil;
    self.folderPath = nil;
}

+ (id) monitor:(NSString *) path withDelegate: (id) delegate;
{
    FolderMonitor *theMonitor = [[self alloc] init];
    theMonitor.delegate = delegate;
    theMonitor.folderPath = path;
    [theMonitor startMonitoring];
    return theMonitor;
}
@end

#define kDocumentChanged	@"DocumentsFolderContentsDidChangeNotification"

@interface DocWatchHelper : NSObject
{
	CFFileDescriptorRef kqref;
    CFRunLoopSourceRef  rls;
}
@property (strong) NSString *path;
+ (id) watcherForPath: (NSString *) aPath;
@end

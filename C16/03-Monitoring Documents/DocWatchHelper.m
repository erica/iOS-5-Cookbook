#import "DocWatchHelper.h"
#import <fcntl.h>
#import <sys/event.h>

@implementation DocWatchHelper
@synthesize path;

- (void)kqueueFired
{
    int             kq;
    struct kevent   event;
    struct timespec timeout = { 0, 0 };
    int             eventCount;
	
    kq = CFFileDescriptorGetNativeDescriptor(self->kqref);
    assert(kq >= 0);
	
    eventCount = kevent(kq, NULL, 0, &event, 1, &timeout);
    assert( (eventCount >= 0) && (eventCount < 2) );
	
    if (eventCount == 1) 
		[[NSNotificationCenter defaultCenter] postNotificationName:kDocumentChanged object:self];
	
    CFFileDescriptorEnableCallBacks(self->kqref, kCFFileDescriptorReadCallBack);
}

static void KQCallback(CFFileDescriptorRef kqRef, CFOptionFlags callBackTypes, void *info)
{
    DocWatchHelper *helper = (DocWatchHelper *)(__bridge id)(CFTypeRef) info;
    [helper kqueueFired];
}

- (void) beginGeneratingDocumentNotificationsInPath: (NSString *) docPath
{
    int                     dirFD;
    int                     kq;
    int                     retVal;
    struct kevent           eventToAdd;
    CFFileDescriptorContext context = { 0, (void *)(__bridge CFTypeRef) self, NULL, NULL, NULL };
	
    dirFD = open([docPath fileSystemRepresentation], O_EVTONLY);
    assert(dirFD >= 0);
	
    kq = kqueue();
    assert(kq >= 0);
	
    eventToAdd.ident  = dirFD;
    eventToAdd.filter = EVFILT_VNODE;
    eventToAdd.flags  = EV_ADD | EV_CLEAR;
    eventToAdd.fflags = NOTE_WRITE;
    eventToAdd.data   = 0;
    eventToAdd.udata  = NULL;
	
    retVal = kevent(kq, &eventToAdd, 1, NULL, 0, NULL);
    assert(retVal == 0);

    self->kqref = CFFileDescriptorCreate(NULL, kq, true, KQCallback, &context);
    rls = CFFileDescriptorCreateRunLoopSource(NULL, self->kqref, 0);
    assert(rls != NULL);
	
    CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
    CFRelease(rls);
    CFFileDescriptorEnableCallBacks(self->kqref, kCFFileDescriptorReadCallBack);
}

- (void) dealloc
{
    self.path = nil;
    CFRunLoopRemoveSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
    CFFileDescriptorDisableCallBacks(self->kqref, kCFFileDescriptorReadCallBack);
}

+ (id) watcherForPath: (NSString *) aPath
{
    DocWatchHelper *watcher = [[self alloc] init];
    watcher.path = aPath;
    [watcher beginGeneratingDocumentNotificationsInPath:aPath];
    return watcher;
}
@end

/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */

#import "ImageDocument.h"
#define SAFE_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)

NSFileVersion *laterVersion(NSFileVersion *first, NSFileVersion *second)
{
    NSDate *firstDate = first.modificationDate;
    NSDate *secondDate = second.modificationDate;    
    return ([firstDate compare:secondDate] != NSOrderedDescending) ? second : first;
}

@implementation ImageDocument
@synthesize image, delegate;
- (NSString *) stateDescription
{
    if (!self.documentState) return @"Document state is normal";
    
    NSMutableString *string = [NSMutableString string];
    if ((self.documentState & UIDocumentStateClosed) != 0) [string appendString:@"Document is closed\n"];
    if ((self.documentState & UIDocumentStateInConflict) != 0) [string appendString:@"Document is in conflict"];
    if ((self.documentState & UIDocumentStateSavingError) != 0) [string appendString:@"Document is experiencing saving error"];
    if ((self.documentState & UIDocumentStateEditingDisabled) != 0) [string appendString:@"Document editing is disbled" ];
    
    return string;    
}

- (BOOL) loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    NSLog(@"Loading external content");
    self.image = nil;
    if ([contents length] > 0)
        self.image = [[UIImage alloc] initWithData:contents];
    SAFE_PERFORM_WITH_ARG(delegate, @selector(imageUpdated:), self);
    
    return YES;
}

- (id) contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    NSLog(@"Publishing content");
    return UIImageJPEGRepresentation(self.image, 0.75f);
}
@end


/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


// Conflict resolution
NSFileVersion *laterVersion(NSFileVersion *first, NSFileVersion *second);

#pragma mark UIDocument
@interface ImageDocument : UIDocument 
@property (readonly) NSString *stateDescription; // debug
@property (strong) UIImage *image;
@property (weak) id delegate;
@end

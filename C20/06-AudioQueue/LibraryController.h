/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface LibraryController : UITableViewController <AVAudioPlayerDelegate>
{
	NSArray				*fileList;
	AVAudioPlayer		*player;
}
@end

/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.x Edition
 BSD License, Use at your own risk
 */


#import "LibraryController.h"

#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@implementation LibraryController

- (void) loadFileList
{
    NSArray *matchArray = [NSArray arrayWithObject:@"aif"];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:DOCUMENTS_FOLDER error:nil];
	fileList = [contents pathsMatchingExtensions:matchArray];
}

- (id) init
{
	if (!(self = [super init])) return nil;

	self.title = @"Library";
	[self loadFileList];

	return self;
}

- (void) viewWillDisappear:(BOOL) animated
{
	// Pause playback before leaving this view
	if (player) 
	{
		[player stop];
		player = nil;
	}
	[super viewWillDisappear: animated];
}

- (void) viewWillAppear: (BOOL) animated
{
	// Update the table to display any new items
	[self.tableView reloadData];
	if ([self.tableView indexPathForSelectedRow]) 
		[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

// utility
- (void) deselect
{	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)aPlayer successfully:(BOOL)flag
{
	player = nil;
}

// Respond to user selection by playing the audio
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath // fromIndexPath:(NSIndexPath *)oldIndexPath 
{
	NSString *path = [DOCUMENTS_FOLDER stringByAppendingPathComponent:[fileList objectAtIndex:[newIndexPath row]]];
	
	// Finish any previous playback
	if (player) 
		[player stop];

	player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
	player.delegate = self;
	[player play];
}


// Editing
-(void)enterEditMode
{
	if ([self.tableView indexPathForSelectedRow]) [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Done", @selector(leaveEditMode));
	[self.tableView setEditing:YES animated:YES];
}

-(void)leaveEditMode
{
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Edit", @selector(enterEditMode));
	[self.tableView setEditing:NO animated:YES];
}

// Delete the selected file
- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSString *path = [DOCUMENTS_FOLDER stringByAppendingPathComponent:[fileList objectAtIndex:[indexPath row]]];
	[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
	[self loadFileList];
	[self.tableView reloadData];
}

// Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return fileList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:@"basic"];
	if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"basic"];
	cell.textLabel.text = [fileList objectAtIndex:[indexPath row]];
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	return cell;
}

// View initialization
- (void) loadView
{
	[super loadView];
	self.tableView.rowHeight = 48.0f;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Edit", @selector(enterEditMode));
}
@end
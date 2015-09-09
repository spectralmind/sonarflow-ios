#import "SFEditPlaylistSection.h"

#import "SFPlaylist.h"

static const NSUInteger kActionSheetClearTag = 1;
static const NSUInteger kActionSheetDeleteTag = 2;

@interface SFEditPlaylistSection () <UIActionSheetDelegate>

@end


@implementation SFEditPlaylistSection {
	@private
	NSObject<SFPlaylist> *playlist;
}

- (id)initWithPlaylist:(NSObject<SFPlaylist> *)thePlaylist {
    self = [super init];
    if (self) {
		playlist = thePlaylist;
		[[NSBundle mainBundle] loadNibNamed:@"PlaylistHeaderCell" owner:self options:nil];
    }
    return self;
}


@synthesize delegate;
@synthesize title;
@synthesize editingHeaderCell;
@synthesize normalHeaderCell;

- (NSUInteger)numberOfRows {
	return 1;
}

- (CGFloat)heightForRow:(NSUInteger)row inTableView:(UITableView *)tableView {
	return tableView.rowHeight;
}

- (UITableViewCell *)cellForRow:(NSUInteger)row inTableView:(UITableView *)tableView {
	if([self.delegate isEditing]) {
		return self.editingHeaderCell;
	}
	else {
		return self.normalHeaderCell;
	}
}

- (NSObject<SFMediaItem> *)mediaItemForRow:(NSUInteger)row {
	return nil;
}

- (BOOL)canSelectRow:(NSUInteger)row {
	return NO;
}

- (BOOL)hasDetailViewControllerForRow:(NSUInteger)row {
	return NO;
}

- (UIViewController *)detailViewControllerForRow:(NSUInteger)row factory:(MediaViewControllerFactory *)factory {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (void)handleSelectRow:(NSUInteger)row {
	[self doesNotRecognizeSelector:_cmd];
}

- (IBAction)toggleEdit {
	[self.delegate toggleEditing];
	[self.delegate reloadRows:[NSIndexSet indexSetWithIndex:0] ofSection:self];
}

- (IBAction)confirmClearPlaylist {
	NSString *clearTitle = NSLocalizedString(@"Clear Playlist",
											 @"Title for the button that confirms clearing a playlist");
	NSString *cancelTitle = NSLocalizedString(@"Cancel",
											  @"Title for a cancel button");
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelTitle destructiveButtonTitle:clearTitle otherButtonTitles:nil];
	actionSheet.tag = kActionSheetClearTag;
	[actionSheet showInView:[self.delegate tableView]];
}

- (IBAction)confirmDeletePlaylist {
	NSString *deleteTitle = NSLocalizedString(@"Delete Playlist",
											  @"Title for the button that confirms deleting a playlist");
	NSString *cancelTitle = NSLocalizedString(@"Cancel",
											  @"Title for a cancel button");
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelTitle destructiveButtonTitle:deleteTitle otherButtonTitles:nil];
	actionSheet.tag = kActionSheetDeleteTag;
	[actionSheet showInView:[self.delegate tableView]];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	}
	
	switch(actionSheet.tag) {
		case kActionSheetClearTag:
			[self clearPlaylist];
			break;
		case kActionSheetDeleteTag:
			[self deletePlaylist];
			break;
		default:
			NSAssert(0, @"Unknown action sheet");
			break;
	}
}

- (void)clearPlaylist {
	[playlist clear];
	[self.delegate reloadAllRowsOfSection:self];
}

- (void)deletePlaylist {
	[playlist deleteList];
	[self.delegate popViewControllerAnimated:YES];
}

@end

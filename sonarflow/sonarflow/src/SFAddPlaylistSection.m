#import "SFAddPlaylistSection.h"

#import "AlertPrompt.h"
#import "SFMediaLibrary.h"
#import "SFPlaylist.h"
#import "SFPlaylistsViewDelegate.h"

#ifdef SF_FREE
	#import "FullVersionAlert.h"
	static const NSUInteger kMaxPlaylists = 2;
#else
	static const NSUInteger kMaxPlaylists = -1;
#endif

@interface SFAddPlaylistSection () <UIAlertViewDelegate>

@end


@implementation SFAddPlaylistSection {
	@private
	NSObject<SFMediaLibrary> *library;
#ifdef SF_FREE
	FullVersionAlert *fullVersionAlert;
#endif
}

- (id)init {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)initWithLibrary:(NSObject<SFMediaLibrary> *)theLibrary {
	self = [super init];
	if(self) {
		library = theLibrary;
	}
	return self;
}


@synthesize delegate;
@synthesize title;
@synthesize playlistDelegate;

- (NSUInteger)numberOfRows {
	return 1;
}

- (CGFloat)heightForRow:(NSUInteger)row inTableView:(UITableView *)tableView {
	return tableView.rowHeight;
}

- (UITableViewCell *)cellForRow:(NSUInteger)row inTableView:(UITableView *)tableView {
    static NSString *CellIdentifier = @"AddPlaylistCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	cell.textLabel.text = NSLocalizedString(@"Add Playlist...",
											@"Title for row that creates a new playlist");;
	return cell;
}

- (NSObject<SFMediaItem> *)mediaItemForRow:(NSUInteger)row {
	return nil;
}

- (BOOL)canSelectRow:(NSUInteger)row {
	return YES;
}

- (BOOL)hasDetailViewControllerForRow:(NSUInteger)row {
	return NO;
}

- (UIViewController *)detailViewControllerForRow:(NSUInteger)row factory:(MediaViewControllerFactory *)factory {
	NSAssert(0, @"Unexpected call");
	return nil;
}

- (void)handleSelectRow:(NSUInteger)row {
	[self addPlaylist];
}

#ifdef SF_FREE

	- (void)showFullVersionAlert {
		if(fullVersionAlert == nil) {
			fullVersionAlert = [[FullVersionAlert alloc] init];
		}
		[fullVersionAlert show];
	}

#else

	- (void)showFullVersionAlert {
	}

#endif

- (void)addPlaylist {
	if(kMaxPlaylists > 0 && [library.playlists count] >= kMaxPlaylists) {
		[self showFullVersionAlert];
		return;
	}
	
	NSString *promptTitle = NSLocalizedString(@"New Playlist",
											  @"Title for playlist name prompt");
	NSString *placeholder = NSLocalizedString(@"Title",
											  @"Placheholder within the playlist name text field");
	NSString *saveTitle = NSLocalizedString(@"Save",
											@"Title for a save button");
	NSString *cancelTitle = NSLocalizedString(@"Cancel",
											  @"Title for a cancel button");
	
	AlertPrompt *prompt = [[AlertPrompt alloc] initWithTitle:promptTitle
													delegate:self
										   cancelButtonTitle:cancelTitle
											   okButtonTitle:saveTitle
										textFieldPlaceholder:placeholder];
	[prompt show];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	NSAssert([alertView isKindOfClass:[AlertPrompt class]], @"Invalid alert prompt class");
    if(buttonIndex == [alertView cancelButtonIndex]) {
		return;
	}

	NSString *playlistName = [(AlertPrompt *)alertView enteredText];
	if([playlistName length] > 0) {
		[self addPlaylistWithName:playlistName];
	}
}

- (void)addPlaylistWithName:(NSString *)playlistName {
	NSObject<SFPlaylist> *newPlaylist = [library newPlaylistWithName:playlistName];	
	[self.playlistDelegate addedPlaylist:newPlaylist];
}

@end

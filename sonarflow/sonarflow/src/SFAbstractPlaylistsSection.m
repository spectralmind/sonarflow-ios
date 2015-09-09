#import "SFAbstractPlaylistsSection.h"

#import "SFPlaylist.h"
#import "SFPlaylistsViewDelegate.h"

@implementation SFAbstractPlaylistsSection


@synthesize delegate;
@synthesize title;
@synthesize playlistDelegate;
@synthesize showDisclosureIndicator;

- (NSUInteger)numberOfRows {
	[self doesNotRecognizeSelector:_cmd];
	return 0;
}

- (CGFloat)heightForRow:(NSUInteger)row inTableView:(UITableView *)tableView {
	return tableView.rowHeight;
}

- (UITableViewCell *)cellForRow:(NSUInteger)row inTableView:(UITableView *)tableView {
    static NSString *CellIdentifier = @"PlaylistCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	id<SFPlaylist> playlist = [self playlistForRow:row];
	cell.textLabel.text = [playlist name];
	if(showDisclosureIndicator) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	return cell;
}

- (NSObject<SFMediaItem> *)mediaItemForRow:(NSUInteger)row {
	return [self playlistForRow:row];
}

- (NSObject<SFPlaylist> *)playlistForRow:(NSUInteger)row {
	[self doesNotRecognizeSelector:_cmd];
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
	[self.playlistDelegate selectedPlaylist:[self playlistForRow:row]];
}

@end

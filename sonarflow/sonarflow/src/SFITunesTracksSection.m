#import "SFITunesTracksSection.h"

#import "ImageFactory.h"
#import "SFMediaItemHelper.h"
#import "SFMediaPlayer.h"
#import "SFITunesTrackCellView.h"
#import "SFITunesAudioTrack.h"

@implementation SFITunesTracksSection

- (UITableViewCell *)cellForChildItem:(id<SFMediaItem>)childItem atRow:(NSUInteger)row inTableView:(UITableView *)tableView {
	NSAssert([childItem isKindOfClass:[SFITunesAudioTrack class]], @"Unexpected child");
	SFITunesAudioTrack *childTrack = (SFITunesAudioTrack *)childItem;
	
	SFITunesTrackCellView *cell = [SFITunesTrackCellView trackCellForTableView:tableView withBuyUrl:childTrack.buyLink imageFactory:self.imageFactory];
	cell.textLabel.text = [childItem name];
	NSString *summary = [SFMediaItemHelper summaryForMediaItem:childItem
												includingAlbum:self.showAlbumName
														artist:self.showArtistName];
	cell.detailTextLabel.text = summary;
	
	if([self.player isNowPlayingItem:childItem]) {
		[cell setNowPlayingImage:self.imageFactory.nowPlayingImage];
	}
	else {
		[cell setNowPlayingImage:nil];
	}
		
	return cell;
}

@end

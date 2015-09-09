#import "SFSpotifyTracksSection.h"

#import "ImageFactory.h"
#import "SFMediaItemHelper.h"
#import "SFMediaPlayer.h"
#import "SFSpotifyTrack.h"
#import "SFSpotifyTrackCellView.h"

@implementation SFSpotifyTracksSection

//TODO: Observe "starred" for all tracks

- (UITableViewCell *)cellForChildItem:(id<SFMediaItem>)childItem atRow:(NSUInteger)row inTableView:(UITableView *)tableView {
	NSAssert([childItem isKindOfClass:[SFSpotifyTrack class]], @"Unexpected child");
	SFSpotifyTrack *childTrack = (SFSpotifyTrack *)childItem;
	
	SFSpotifyTrackCellView *cell = [SFSpotifyTrackCellView trackCellForTableView:tableView withImageFactory:self.imageFactory];
	cell.textLabel.text = [childItem name];
	NSString *summary = [SFMediaItemHelper summaryForMediaItem:childItem
												includingAlbum:self.showAlbumName
														artist:self.showArtistName];
	cell.detailTextLabel.text = summary;
	[cell setTrackDuration:[childItem duration]];
	
	if([self.player isNowPlayingItem:childItem]) {
		[cell setNowPlayingImage:self.imageFactory.nowPlayingImage];
	}
	else {
		[cell setNowPlayingImage:nil];
	}
	
	cell.starred = childTrack.starred;
	__block SFSpotifyTracksSection *blockSelf = self;
	cell.setStarredBlock = ^(BOOL starred) {
		childTrack.starred = starred;
		[blockSelf.delegate reloadRows:[NSIndexSet indexSetWithIndex:row] ofSection:blockSelf];
	};
	return cell;
}

@end

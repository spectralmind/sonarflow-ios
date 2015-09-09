#import "SFTracksSection.h"

#import "SFMediaItem.h"
#import "SFMediaItemHelper.h"
#import "ImageFactory.h"
#import "TrackCellView.h"
#import "SFMediaPlayer.h"
#import "SFAudioTrack.h"

static NSString * const kTrackCellIdentifier = @"TrackCell";

@interface SFTracksSection ()

@end

@implementation SFTracksSection {
	@private
}

- (id)init {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)initWithMediaItem:(NSObject<SFMediaItem> *)theMediaItem imageFactory:(ImageFactory *)theImageFactory {
    self = [super initWithMediaItem:theMediaItem];
    if (self) {
		imageFactory = theImageFactory;
    }
    return self;
}

- (void)dealloc {
	[player removeObserver:self forKeyPath:@"nowPlayingLeaf"];
}

@synthesize imageFactory;
@synthesize showTrackNumbers;
@synthesize player;
- (void)setPlayer:(NSObject<SFMediaPlayer> *)newPlayer {
	if(player == newPlayer) {
		return;
	}
	[player removeObserver:self forKeyPath:@"nowPlayingLeaf"];
	player = newPlayer;
	[player addObserver:self forKeyPath:@"nowPlayingLeaf" options:NSKeyValueObservingOptionOld context:NULL];
}

- (UITableViewCell *)cellForChildItem:(id<SFMediaItem>)childItem atRow:(NSUInteger)row inTableView:(UITableView *)tableView {
	TrackCellView *cell = (TrackCellView *)[tableView dequeueReusableCellWithIdentifier:kTrackCellIdentifier];
	NSAssert(cell == nil || [cell isKindOfClass:[TrackCellView class]], @"Unexpected track cell class type");
	
    if(cell == nil) {
		cell = [[TrackCellView alloc] initWithReuseIdentifier:kTrackCellIdentifier];
    }
	
	cell.textLabel.text = [childItem name];
	NSString *summary = [SFMediaItemHelper summaryForMediaItem:childItem
												includingAlbum:self.showAlbumName
														artist:self.showArtistName];
	cell.detailTextLabel.text = summary;
	
	if(self.showTrackNumbers) {
		[cell setTrackNumber:[NSNumber numberWithInt:row + 1]];
	}
	
	[cell setTrackDuration:[childItem duration]];
	
	if([self.player isNowPlayingItem:childItem]) {
		[cell setNowPlayingImage:imageFactory.nowPlayingImage];
	}
	else {
		[cell setNowPlayingImage:nil];
	}
	
    return cell;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == player) {
		[self updateNowPlayingRowFromTrack:[change objectForKey:NSKeyValueChangeOldKey] toTrack:(id<SFAudioTrack>)player.nowPlayingLeaf];
    }
	else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)updateNowPlayingRowFromTrack:(id<SFAudioTrack>)oldTrack toTrack:(id<SFAudioTrack>)newTrack {
	NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
	[indexes addIndexes:[self indexesOfTrack:oldTrack]];
	[indexes addIndexes:[self indexesOfTrack:newTrack]];
	if([indexes count] > 0) {
		[self.delegate reloadRows:indexes ofSection:self];
	}
}

- (NSIndexSet *)indexesOfTrack:(id<SFAudioTrack>)track {
	NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
	NSUInteger index = 0;
	for(id<SFAudioTrack> item in self.mediaItem.children) {
		if([item isEquivalentToAudioTrack:track]) {
			[indexes addIndex:index];
		}
		++index;
	}
	return indexes;
}

@end

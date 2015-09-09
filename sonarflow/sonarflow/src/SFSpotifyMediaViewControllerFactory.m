#import "SFSpotifyMediaViewControllerFactory.h"

#import "SFSpotifyTracksSection.h"

@implementation SFSpotifyMediaViewControllerFactory

- (id<SFTableViewSection>)tracksSectionForMediaItem:(NSObject<SFMediaItem> *)mediaItem withAlbumNames:(BOOL)showAlbumNames artistNames:(BOOL)showArtistNames  trackNumbers:(BOOL)showTrackNumbers{
	//TODO: Refactor to use a SFTrackSection with different SFTrackCellFactory (tbd) instance
	SFSpotifyTracksSection *tracksSection = [[SFSpotifyTracksSection alloc] initWithMediaItem:mediaItem imageFactory:self.imageFactory];
	tracksSection.title = @"Tracks";
	tracksSection.showAlbumName = showAlbumNames;
	tracksSection.showArtistName = showArtistNames;
	tracksSection.showTrackNumbers = showTrackNumbers;
	tracksSection.player = self.player;
	return tracksSection;
}

- (NSArray *)childrenSectionsForArtist:(NSObject<SFMediaItem> *)artist singleArtist:(BOOL)singleArtist {
	return [NSArray arrayWithObject:[self tracksSectionForMediaItem:artist withAlbumNames:YES artistNames:NO trackNumbers:NO]];
}

@end
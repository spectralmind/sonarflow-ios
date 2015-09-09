#import "SFTrackTestHelper.h"

#import <MediaPlayer/MediaPlayer.h>
#import <OCMock/OCMock.h>

@implementation SFTrackTestHelper

+ (SFTrack *)trackWithGenre:(NSString *)genre artist:(NSString *)artist albumArtist:(NSString *)albumArtist album:(NSString *)album compilation:(BOOL)compilation trackNumber:(NSNumber *)trackNumber artworkFactory:(ArtworkFactory *)theArtworkFactory nameGenreMapper:(NameGenreMapper *)theNameGenreMapper player:(SFNativeMediaPlayer *)thePlayer {
	return [self trackWithId:0 genre:genre artist:artist albumArtist:albumArtist album:album compilation:compilation disc:0 trackNumber:trackNumber artworkFactory:theArtworkFactory nameGenreMapper:theNameGenreMapper player:thePlayer];
}

+ (SFTrack *)trackWithId:(NSUInteger)trackId genre:(NSString *)genre artist:(NSString *)artist albumArtist:(NSString *)albumArtist album:(NSString *)album compilation:(BOOL)compilation disc:(NSUInteger)disc trackNumber:(NSNumber *)trackNumber artworkFactory:(ArtworkFactory *)theArtworkFactory nameGenreMapper:(NameGenreMapper *)theNameGenreMapper player:(SFNativeMediaPlayer *)thePlayer {
	id mediaItemMock = [OCMockObject mockForClass:[MPMediaItem class]];
	[[[mediaItemMock stub] andReturn:[NSNumber numberWithUnsignedInteger:trackId]] valueForProperty:MPMediaItemPropertyPersistentID];
	[[[mediaItemMock stub] andReturn:@"Test-Track"] valueForProperty:MPMediaItemPropertyTitle];
	[[[mediaItemMock stub] andReturn:genre] valueForProperty:MPMediaItemPropertyGenre];
	[[[mediaItemMock stub] andReturn:artist] valueForProperty:MPMediaItemPropertyArtist];
    [[[mediaItemMock stub] andReturn:albumArtist] valueForProperty:MPMediaItemPropertyAlbumArtist];
	[[[mediaItemMock stub] andReturn:album] valueForProperty:MPMediaItemPropertyAlbumTitle];
	[[[mediaItemMock stub] andReturn:[NSNumber numberWithBool:compilation]] valueForProperty:MPMediaItemPropertyIsCompilation];
	[[[mediaItemMock stub] andReturn:[NSNumber numberWithUnsignedInteger:disc]] valueForProperty:MPMediaItemPropertyDiscNumber];
	[[[mediaItemMock stub] andReturn:trackNumber] valueForProperty:MPMediaItemPropertyAlbumTrackNumber];
	return [[SFTrack alloc] initWithItem:mediaItemMock artworkFactory:theArtworkFactory nameGenreMapper:theNameGenreMapper player:thePlayer];
}

@end

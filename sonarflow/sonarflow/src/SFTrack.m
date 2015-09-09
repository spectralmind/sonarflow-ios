#import "SFTrack.h"

#import <MediaPlayer/MediaPlayer.h>

#import "ArtworkFactory.h"
#import "GenreDefinition.h"
#import "MediaViewControllerFactory.h"
#import "NameGenreMapper.h"
#import "SFAlbum.h"
#import "SFGenre.h"
#import "SFMediaItem.h"
#import "SFNativeMediaPlayer.h"
#import "TrackComparator.h"

@interface SFTrack ()

@property (nonatomic, readwrite, strong) MPMediaItem *mediaItem;

@end


@implementation SFTrack {
	MPMediaItem *mediaItem;
	ArtworkFactory *artworkFactory;
	NameGenreMapper *nameGenreMapper;
	SFNativeMediaPlayer *player;
	
	NSNumber *mediaItemId;
	NSString *name;
	NSString *genre;
	NSString *artist;
	NSNumber *compilation;
	NSString *albumArtist;
	NSString *sortableAlbumArtist;
	NSString *album;
	NSString *sortableAlbum;
	NSNumber *duration;
	NSNumber *trackNumber;
	NSNumber *discNumber;
}

+ (NSString *)compilationArtist {
	return NSLocalizedString(@"Compilations",
							 @"Placeholder name for the 'artist' of compilation albums");
}

+ (NSString *)unknownArtist {
	return NSLocalizedString(@"Unknown artist",
							  @"Replacement for empty artist fields");
}

+ (NSString *)unknownAlbum {
	return NSLocalizedString(@"Unknown album",
							 @"Replacement for empty album fields");
}

- (id)initWithItem:(MPMediaItem *)item artworkFactory:(ArtworkFactory *)theArtworkFactory nameGenreMapper:(NameGenreMapper *)theNameGenreMapper player:(SFNativeMediaPlayer *)thePlayer {
	if(self = [super init]) {
		mediaItem = item;
		artworkFactory = theArtworkFactory;
		nameGenreMapper = theNameGenreMapper;
		player = thePlayer;
	}
	return self;
}


- (NSString *)name {
	if(name == nil) {
		name = [mediaItem valueForProperty:MPMediaItemPropertyTitle];
	}
	
	return name;
}

- (id)key {
	return self.mediaItemId;
}

@synthesize parent;

- (NSNumber *)duration {
	if(duration == nil) {
		duration = [mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
	}
	
	return duration;
}

- (BOOL)mayHaveChildren {
	return NO;
}

- (BOOL)showAsBubble {
	return YES;
}

- (CGFloat)relativeSize {
	NSAssert([parent isKindOfClass:[SFAlbum class]], @"dangling track!");
	SFAlbum *parentAlbum = (SFAlbum *)parent;
	
	return 1.0 / parentAlbum.tracks.count;
}

- (BOOL)hasDetailViewController {
	return NO;
}

- (UIViewController *)createDetailViewControllerWithFactory:(MediaViewControllerFactory *)factory {
	return [factory viewControllerForTrack:self];
}

- (NSArray *)children {
	return @[self];
}

- (BOOL)mayHaveImage {
	return YES;
}

- (UIImage *)imageWithSize:(CGSize)size {
	return [artworkFactory artworkForMediaItem:self.mediaItem withSize:size];
}

- (void)startPlayback {
	[player playMediaItem:self];
}

- (void)startPlaybackAtChildIndex:(NSUInteger)childIndex {
	if(childIndex > 0) {
		return;
	}
	
	[player playMediaItem:self];
}

- (NSComparisonResult)compareKeys:(id<SFMediaItem>)other {
	return [self.key compare:other.key];
}

- (NSUInteger)numTracks {
	return 1;
}

- (NSArray *)tracks {
	return [NSArray arrayWithObject:self];
}

- (NSString *)artistName {
	if(artist == nil) {
		artist = [mediaItem valueForProperty:MPMediaItemPropertyArtist];
		if([artist length] == 0) {
			artist = [SFTrack unknownArtist];
		}
	}
	
	return artist;
}

- (NSString *)albumName {
	if(album == nil) {
		album = [mediaItem valueForProperty:MPMediaItemPropertyAlbumTitle];
		if([album length] == 0) {
			album = [SFTrack unknownAlbum];
		}
	}
	
	return album;
}

@synthesize mediaItem;
@synthesize genre;

- (NSNumber *)mediaItemId {
	if(mediaItemId == nil) {
		mediaItemId = [mediaItem valueForProperty:MPMediaItemPropertyPersistentID];
	}

	return mediaItemId;
}

- (NSString *)genre {
	if(genre == nil) {
		genre = [mediaItem valueForProperty:MPMediaItemPropertyGenre];
		if(genre == nil) {
			genre = @"";
		}
	}

	return genre;
}

- (NSString *)albumArtistName {
	if(albumArtist == nil) {
		albumArtist = [self computedAlbumArtist];
	}

	return albumArtist;
}

- (NSString *)computedAlbumArtist {
	if(self.isCompilation) {
		return [SFTrack compilationArtist];
	}

	NSString *newAlbumArtist = [mediaItem valueForProperty:MPMediaItemPropertyAlbumArtist];
	if([newAlbumArtist length] == 0) {
		return [self artistName];
	}

	return newAlbumArtist;
}

- (NSString *)sortableAlbumArtist {
	if(sortableAlbumArtist == nil) {
		sortableAlbumArtist = [[self albumArtistName] lowercaseString];
	}
	
	return sortableAlbumArtist;
}

- (BOOL)isCompilation {
	if(compilation == nil) {
		compilation = [mediaItem valueForProperty:MPMediaItemPropertyIsCompilation];
	}

	return [compilation boolValue];
}

- (NSString *)sortableAlbum {
	if(sortableAlbum == nil) {
		sortableAlbum = [[self albumName] lowercaseString];
	}
	
	return sortableAlbum;
}

- (NSNumber *)trackNumber {
	if(trackNumber == nil) {
		trackNumber = [mediaItem valueForProperty:MPMediaItemPropertyAlbumTrackNumber];
	}
    
	return trackNumber;
}

- (NSNumber *)discNumber {
	if(discNumber == nil) {
		discNumber = [mediaItem valueForProperty:MPMediaItemPropertyDiscNumber];
	}
    
	return discNumber;
}

- (NSArray *)keyPath {
	NSString *mappedGenreName = [nameGenreMapper mappedNameForGenreName:self.genre usingArtistName:self.artistName];
	NSAssert(mappedGenreName != nil, @"Missing mapped genre for name");

	return @[[SFGenre keyForGenreName:mappedGenreName], self.sortableAlbumArtist, self.sortableAlbum, self.key];	
}

- (BOOL)isEquivalentToAudioTrack:(id<SFAudioTrack>)otherTrack {
	if([otherTrack conformsToProtocol:@protocol(SFNativeTrack)] == NO) {
		return NO;
	}
	
	return [TrackComparator isTrack:self equalToTrack:(id<SFNativeTrack>)otherTrack]; 
}

- (NSString *)description {
	return [NSString stringWithFormat:@"id: %@, name: %@, genre: %@, artist: %@, compilation: %d, albumArtist: %@, album: %@, discNumber: %@, trackNumber: %@",
			self.mediaItemId, self.name, self.genre, [self artistName], (int) self.compilation, [self albumArtistName], [self albumName], self.discNumber, self.trackNumber];
}

- (NSString *)artistNameForDiscovery {
	return [self artistName];
}

- (NSString *)countToShow {
	return [NSString stringWithFormat:@"%@", self.trackNumber];
}

@end

NSInteger sortTracksByNumber(SFTrack *first, SFTrack *second, void *context) {
    NSInteger result = [first.discNumber compare:second.discNumber];
    if(result == NSOrderedSame) {
        result = [first.trackNumber compare:second.trackNumber];
    }
	
	return result;
}

NSInteger sortTracksByAlbumNumber(SFTrack *first, SFTrack *second, void *context) {
	NSInteger result = [first.sortableAlbum compare:second.sortableAlbum];
	if(result == NSOrderedSame) {
		result = sortTracksByNumber(first, second, NULL);
	}
	
	return result;
}

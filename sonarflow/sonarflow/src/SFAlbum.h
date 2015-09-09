#import <Foundation/Foundation.h>

#import "SFMediaCollection.h"
#import "SFDiscoverableItem.h"

@class SFTrack;
@class MPMediaItem;
@class ArtworkFactory;

@interface SFAlbum : SFMediaCollection <SFDiscoverableItem> {
	ArtworkFactory *artworkFactory;
	BOOL compilation;

	BOOL isSorted;
	NSMutableArray *sortedTracks;

	MPMediaItem *item;
}

- (id)initWithName:(NSString *)theName player:(SFNativeMediaPlayer *)thePlayer artworkFactory:(ArtworkFactory *)theArtworkFactory;

@property (nonatomic, assign, getter = isCompilation) BOOL compilation;

@property (nonatomic, readonly) NSUInteger numTracks;

@property (nonatomic, strong) MPMediaItem *item;

- (void)addTrack:(SFTrack *)track;

@end

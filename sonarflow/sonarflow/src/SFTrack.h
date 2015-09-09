#import <Foundation/Foundation.h>

#import "SFNativeTrack.h"
#import "SFDiscoverableItem.h"

@class MPMediaItem;
@class ArtworkFactory;
@class NameGenreMapper;
@class SFNativeMediaPlayer;

@interface SFTrack : NSObject <SFNativeTrack, SFDiscoverableItem>

+ (NSString *)compilationArtist;
+ (NSString *)unknownArtist;
+ (NSString *)unknownAlbum;

- (id)initWithItem:(MPMediaItem *)item artworkFactory:(ArtworkFactory *)theArtworkFactory nameGenreMapper:(NameGenreMapper *)theNameGenreMapper player:(SFNativeMediaPlayer *)thePlayer;

@property (nonatomic, readwrite, strong) id key;
@property (nonatomic, readwrite, weak) id<SFMediaItem> parent;
@property (nonatomic, readonly, strong) MPMediaItem *mediaItem;
@property (weak, nonatomic, readonly) NSNumber *mediaItemId;
@property (nonatomic, readonly) NSString *genre;
@property (weak, nonatomic, readonly) NSString *albumArtistName;
@property (weak, nonatomic, readonly) NSString *sortableAlbumArtist;
@property (nonatomic, readonly, getter=isCompilation) BOOL compilation;
@property (weak, nonatomic, readonly) NSString *sortableAlbum;
@property (weak, nonatomic, readonly) NSNumber *trackNumber;
@property (weak, nonatomic, readonly) NSNumber *discNumber;

@end

NSInteger sortTracksByNumber(SFTrack *first, SFTrack *second, void *context);
NSInteger sortTracksByAlbumNumber(SFTrack *first, SFTrack *second, void *context);

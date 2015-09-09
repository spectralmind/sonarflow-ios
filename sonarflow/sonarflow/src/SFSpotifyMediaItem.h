#import "SFMediaItem.h"
#import "SFDiscoverableItem.h"

@protocol SFPlaylist;
@class SFSpotifyPlayer;

@protocol SFSpotifyMediaItem <SFMediaItem, SFDiscoverableItem>

@property (nonatomic, readonly, assign, getter = isLoading) BOOL loading;

- (NSArray *)tracks; //Array of SFSpotifyTrack

@end

@interface SFSpotifyMediaItem : NSObject<SFSpotifyMediaItem>

- (id)initWithName:(NSString *)theName key:(id)theKey player:(SFSpotifyPlayer *)thePlayer;

@property (nonatomic, readwrite, assign) id<SFMediaItem> parent;
@property (nonatomic, readonly, assign) NSUInteger size;
@property (nonatomic, readonly) SFSpotifyPlayer *player;

- (id<SFMediaItem, SFPlaylist>)tracksProxy;

@end

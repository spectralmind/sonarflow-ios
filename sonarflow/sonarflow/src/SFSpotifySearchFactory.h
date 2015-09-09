#import <Foundation/Foundation.h>

@protocol SFMediaItem;

@class SFSpotifyPlayer;
@class SFSpotifyArtistSearch;

@interface SFSpotifySearchFactory : NSObject

- (id)initWithPlayer:(SFSpotifyPlayer *)thePlayer;

- (SFSpotifyArtistSearch *)searchForArtistName:(NSString *)name parentForChildren:(id<SFMediaItem>)parent;

@end

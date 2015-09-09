#import <Foundation/Foundation.h>

@protocol SFMediaItem;

@class SPSession;
@class SFSpotifyPlayer;

typedef void (^ArtistResultBlock)(NSArray *topTracks, NSError *error);

@interface SFSpotifyArtistSearch : NSObject

- (id)initWithArtistName:(NSString *)theArtistName session:(SPSession *)theSession player:(SFSpotifyPlayer *)thePlayer parentForChildren:(id<SFMediaItem>)theParent;

- (void)startWithCompletion:(ArtistResultBlock)theCompletionBlock;

@end

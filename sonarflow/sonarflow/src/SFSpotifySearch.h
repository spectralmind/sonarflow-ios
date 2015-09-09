#import <Foundation/Foundation.h>

typedef void (^SearchResultBlock)(NSArray *artists, NSArray *albums, NSArray *tracks, NSArray *playlists, NSError *error);

@class SPSession;

@interface SFSpotifySearch : NSObject

+ (NSString *)queryForArtistName:(NSString *)artistName;

- (id)initWithQuery:(NSString *)theQuery session:(SPSession *)theSession;

- (void)startWithCompletion:(SearchResultBlock)theCompletionBlock;

@end

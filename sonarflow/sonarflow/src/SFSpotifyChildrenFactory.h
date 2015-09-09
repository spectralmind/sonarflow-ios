#import <Foundation/Foundation.h>

@class SFSpotifyFactory;

//TODO: Improve name
@interface SFSpotifyChildrenFactory : NSObject

- (id)initWithFactory:(SFSpotifyFactory *)theFactory;

- (NSArray *)childrenFromSPTracks:(NSArray *)tracks;

@end

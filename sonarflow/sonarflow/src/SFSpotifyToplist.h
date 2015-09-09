#import "SFSpotifyMediaGroup.h"

#import "SFRootItem.h"

@class SFSpotifyPlayer;
@class SFSpotifyChildrenFactory;
@class SPToplist;

@interface SFSpotifyToplist : SFSpotifyMediaGroup <SFRootItem>

- (id)initWithName:(NSString *)theName origin:(CGPoint)theOrigin color:(UIColor *)theColor key:(id)theKey spotifyPlayer:(SFSpotifyPlayer *)theSpotifyPlayer;
@end

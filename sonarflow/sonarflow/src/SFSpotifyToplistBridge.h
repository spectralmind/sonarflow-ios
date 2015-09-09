#import <Foundation/Foundation.h>
#import "SFSpotifyBridge.h"

@class SPToplist;
@class SFSpotifyPlayer;
@class SFSpotifyChildrenFactory;

@interface SFSpotifyToplistBridge : SFSpotifyBridge
- (id)initWithToplist:(SPToplist *)theToplist name:(NSString *)theName origin:(CGPoint)theOrigin color:(UIColor *)theColor key:(id)theKey spotifyPlayer:(SFSpotifyPlayer *)theSpotifyPlayer factory:(SFSpotifyChildrenFactory *)theChildrenFactory;
@end

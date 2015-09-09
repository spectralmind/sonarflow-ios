#import "SFSpotifyMediaGroup.h"

#import "SFPlaylist.h"
#import "SFRootItem.h"

@class SFSpotifyChildrenFactory;
@class SFSpotifyPlayer;
@class SPPlaylist;

@interface SFSpotifyPlaylist : SFSpotifyMediaGroup <SFRootItem, SFPlaylist>

- (id)initWithName:(NSString *)theName key:(id)theKey color:(UIColor *)theColor player:(SFSpotifyPlayer *)thePlayer origin:(CGPoint)theOrigin;

@end

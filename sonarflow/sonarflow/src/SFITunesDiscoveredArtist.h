#import "SFAbstractDiscoveredArtist.h"
#import "SFITunesMediaItem.h"

@class SFITunesPlayer;

@interface SFITunesDiscoveredArtist : SFAbstractDiscoveredArtist <SFITunesMediaItem>

- (id)initWithKey:(RootKey *)theKey name:(NSString *)theName player:(SFITunesPlayer *)thePlayer;

@end

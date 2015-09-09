#import "SFMediaItem.h"
#import "SFDiscoverableItem.h"

@class RootKey;

@interface SFAbstractDiscoveredArtist : NSObject<SFMediaItem, SFDiscoverableItem>

-(id)initWithKey:(RootKey *)theKey name:(NSString *)theName;

@end

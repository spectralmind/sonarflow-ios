#import <Foundation/Foundation.h>

@class SFSpotifyBridge;
@protocol SFMediaItem;

@protocol SFMediaItemContainerDelegate <NSObject>
- (void)bridge:(SFSpotifyBridge *)theBridge discoveredMediaItem:(id<SFMediaItem>)mediaItem;
- (void)bridge:(SFSpotifyBridge *)theBridge removedMediaItem:(id<SFMediaItem>)mediaItem;
@end

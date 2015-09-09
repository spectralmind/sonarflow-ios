#import <Foundation/Foundation.h>

#import "SFMediaItemContainerDelegate.h"

@protocol SFSpotifyMediaItem;

@interface SFSpotifyBridge : NSObject
@property (nonatomic, assign) id<SFMediaItemContainerDelegate> delegate;

- (void)notifyDelegateWithMediaItem:(id<SFSpotifyMediaItem>)item;
@end

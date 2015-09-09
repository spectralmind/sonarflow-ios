#import <Foundation/Foundation.h>

#import "SFMediaPlayer.h"

@protocol SFAudioTrack;
@protocol SFMediaItem;
@class SFPlaybackQueue;

@interface SFAbstractMediaPlayer : NSObject <SFMediaPlayer>

+ (BOOL)isAudioTrack:(id<SFAudioTrack>)audioTrack equivalentToMediaItem:(id<SFMediaItem>)mediaItem;

@property (nonatomic, readwrite, assign) NSTimeInterval nowPlayingLeafPlaybackTime;
@property (nonatomic, readwrite, strong) NSNumber *nowPlayingLeafDuration;

- (void)enableAudioSessionWithCategory:(NSString *)category;
- (void)disableAudioSession;
- (void)togglePlayback;
- (void)publishNowPlayingInfoForQueue:(SFPlaybackQueue *)queue;

@end

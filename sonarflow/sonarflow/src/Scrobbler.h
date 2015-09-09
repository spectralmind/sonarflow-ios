#import <Foundation/Foundation.h>

#import "LastfmSettingsViewControllerDelegate.h"

@class LastfmSettings;
@class Configuration;
@class SNRLastFMEngine;
@protocol ScrobblerDelegate;
@protocol SFMediaItem;

@interface Scrobbler : NSObject

- (id)initWithLastfmEngine:(SNRLastFMEngine *)theLastfmEngine;

@property (nonatomic, copy) LastfmSettings *lastfmSettings;
@property (nonatomic, weak) id<ScrobblerDelegate> delegate;

- (void)nowPlayingLeafChanged:(id<SFMediaItem>)mediaItem;
- (void)playbackStateChangedToPlaying:(BOOL)playing;

- (void)verifyAccountWithUsername:(NSString *)username withPassword:(NSString *)password  completion:(LastfmLoginCompletionBlock)completion;

@end


@protocol ScrobblerDelegate <NSObject>

- (void)scrobblerDidFailToAuthenticate;
- (void)scrobblerSkippedScrobbling;

@end
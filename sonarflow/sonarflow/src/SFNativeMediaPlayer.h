#import "SFAbstractMediaPlayer.h"

#import <MediaPlayer/MediaPlayer.h>

#import "SFMediaPlayer.h"

@protocol SFNativeMediaItem;
@class PersistentStore;
@class SFNativeMediaFactory;

@interface SFNativeMediaPlayer : SFAbstractMediaPlayer

- (id)initWithPersistentStore:(PersistentStore *)store mediaFactory:(SFNativeMediaFactory *)theMediaFactory;

- (void)playMediaItem:(id<SFNativeMediaItem>)mediaItem;
- (void)playMediaItem:(id<SFNativeMediaItem>)mediaItem startingAtIndex:(NSUInteger)startIndex;

@end

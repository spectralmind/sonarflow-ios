#import <UIKit/UIKit.h>

@protocol SFMediaItem;

@protocol PlaybackDelegate

- (void)tappedMediaItem:(id<SFMediaItem>)mediaItem;
- (void)tappedChildIndex:(NSUInteger)index inMediaItem:(id<SFMediaItem>)mediaItem;

@end

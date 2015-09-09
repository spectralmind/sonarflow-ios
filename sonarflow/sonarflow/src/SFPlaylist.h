#import <UIKit/UIKit.h>

#import "SFMediaItem.h"

@protocol SFPlaylist <SFMediaItem>

- (BOOL)isReadOnly;

@optional
- (NSNumber *)order;
- (void)setOrder:(NSNumber *)order;

- (void)moveTrackFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)deleteTrackAtIndex:(NSUInteger)index;
- (void)addMediaItem:(id<SFMediaItem>)mediaItem;

- (void)clear;

- (void)deleteList;

- (BOOL)isEqualToPlaylist:(id<SFPlaylist>)playlist;

@end

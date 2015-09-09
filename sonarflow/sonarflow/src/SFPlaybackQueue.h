#import <Foundation/Foundation.h>

@protocol SFMediaItem;

@interface SFPlaybackQueue : NSObject

@property (nonatomic, assign) BOOL shuffle;
@property (nonatomic, readonly, strong) id currentItem;
@property (nonatomic, readonly, assign) NSUInteger currentItemIndex;
@property (nonatomic, readonly, strong) NSArray *queue;

- (void)replaceQueue:(NSArray *)newQueue;
- (void)replaceQueue:(NSArray *)newQueue startingAtIndex:(NSUInteger)index;
- (void)clearQueue;

- (BOOL)hasNextItem;
- (BOOL)hasPreviousItem;
- (void)skipToNextItem;
- (void)skipToPreviousItem;

@end

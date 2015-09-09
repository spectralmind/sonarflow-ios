#import "SFObserver.h"

@protocol SFArrayObserverDelegate;

@interface SFArrayObserver : SFObserver

- (id)initWithObject:(NSObject *)theObject keyPath:(NSString *)theKeyPath delegate:(id<SFArrayObserverDelegate>)theDelegate;

@end

@protocol SFArrayObserverDelegate <SFObserverDelegate>

@optional
- (void)objects:(NSArray *)objects wereInsertedAtIndexes:(NSIndexSet *)indexes ofObject:(NSObject *)object;
- (void)objects:(NSArray *)objects wereDeletedAtIndexes:(NSIndexSet *)indexes ofObject:(NSObject *)object;
- (void)objects:(NSArray *)oldObjects wereReplacedWithObjects:(NSArray *)newObjects atIndexes:(NSIndexSet *)indexes ofObject:(NSObject *)object;

@end

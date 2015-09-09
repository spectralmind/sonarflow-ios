#import <Foundation/Foundation.h>

typedef void (^SMQueueBlock)(void);

@interface SMRateLimitedQueue : NSObject
- (id)initWithMinimumInterval:(NSTimeInterval)theLimit;

- (void)enqueueWithPriority:(BOOL)priority block:(SMQueueBlock)theWorkBlock;

@end

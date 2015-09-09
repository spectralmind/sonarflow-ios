#import <Foundation/Foundation.h>

@protocol CacheableView <NSObject>

- (void)willBeEnqueuedToCache;

@end

#import "SMRateLimitedQueue.h"

@implementation SMRateLimitedQueue {
	@private
	NSTimeInterval minimumRequestInterval;	
	NSMutableArray *workQueue;
	BOOL idle;
}

- (id)initWithMinimumInterval:(NSTimeInterval)theLimit {
	if (!(self = [super init])) return nil;
	NSLog(@"SMRateLimitedQueue: Coming to life at %x!\n", (int)self);
	minimumRequestInterval = theLimit;
	workQueue = [[NSMutableArray alloc] init];
	idle = YES;
	return self;
}

- (id)init {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}


- (void)dealloc {
	NSLog(@"SMRateLimitedQueue: Someone's trying to destroy me!\n");
}


- (void)enqueueWithPriority:(BOOL)priority block:(SMQueueBlock)theWorkBlock {
	BOOL startNow = NO;
	
	@synchronized(workQueue) {
		SMQueueBlock blockCopy = [theWorkBlock copy];
		if(priority) {
			[workQueue insertObject:blockCopy atIndex:0];
		}
		else {
			[workQueue addObject:blockCopy];
		}

		if(idle) {
			idle = NO;
			startNow = YES;
		}
	}
	
	if(startNow) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self dispatcher];
		});
	}
}

- (void)dispatcher {
	SMQueueBlock __strong nextblock;
	@synchronized(workQueue) {
		if([workQueue count] == 0) {
			idle = YES;
			return;
		}
		
		nextblock = [workQueue objectAtIndex:0];
		[workQueue removeObjectAtIndex:0];
	}

	nextblock();
		
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, minimumRequestInterval * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self dispatcher];
	});
}

@end

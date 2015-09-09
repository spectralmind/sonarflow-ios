//
//  SMRateLimiterTests.m
//  SMArtist
//
//  Created by Arvid Staub on 20.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SMRateLimiterTests.h"
#import "SMRateLimitedQueue.h"

@implementation SMRateLimiterTests

- (void)setUp {
	
}

- (void)drainMainQueue {
	NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:.2];
    while([loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
}

- (void)testQueueDoesDispatchBlocks {
	SMRateLimitedQueue *sut = [[SMRateLimitedQueue alloc] initWithMinimumInterval:0.1];
	
	__block BOOL success = NO;
	[sut enqueueWithPriority:NO block:^{ success = YES; }];
	[self drainMainQueue];
	
	STAssertTrue(success, @"The enqueued block was not dispatched.");
}

- (void)testQueueDispatchesMoreThanOneBlock {
	SMRateLimitedQueue *sut = [[SMRateLimitedQueue alloc] initWithMinimumInterval:0.01];
	
	__block int success = 0;
	[sut enqueueWithPriority:NO block:^{ success++; }];
	[sut enqueueWithPriority:NO block:^{ success++; }];
	[sut enqueueWithPriority:NO block:^{ success++; }];
	[sut enqueueWithPriority:NO block:^{ success++; }];
	[sut enqueueWithPriority:NO block:^{ success++; }];
	[self drainMainQueue];
	
	STAssertTrue(success == 5, @"Some enqueued blocks were not dispatched.");	
}

- (void)testQueueRespectsRateLimit {
	
	NSTimeInterval timespan = 0.1;
	
	SMRateLimitedQueue *sut = [[SMRateLimitedQueue alloc] initWithMinimumInterval:timespan];
	
	__block NSTimeInterval beginFirstBlock;
	__block NSTimeInterval beginSecondBlock;
	NSDate *start = [NSDate date];
	
	[sut enqueueWithPriority:NO block:^{ beginFirstBlock = -[start timeIntervalSinceNow]; }];
	[sut enqueueWithPriority:NO block:^{ beginSecondBlock = -[start timeIntervalSinceNow]; }];

	[self drainMainQueue];

	NSLog(@"Dispatcher: first %f, second %f\n", beginFirstBlock, beginSecondBlock);
	STAssertTrue(beginSecondBlock >= (beginFirstBlock + timespan), @"second block executed too soon!");
}

- (void)testQueueStartsImmediatelyWhenEmpty {
	
}

@end

#import "SFPlaybackQueueTests.h"

#import "SFPlaybackQueue.h"

static const NSUInteger kNumItems = 10;

@implementation SFPlaybackQueueTests {
	SFPlaybackQueue *sut;
	NSMutableArray *queue;
}

- (void)setUp {
	queue = [NSMutableArray arrayWithCapacity:kNumItems];
	for(int i = 0; i < kNumItems; ++i) {
		[queue addObject:[NSNumber numberWithInt:i]];
	}
	
	sut = [[SFPlaybackQueue alloc] init];
}

- (void)testSetQueue {
	NSUInteger index = 3;
	[sut replaceQueue:queue startingAtIndex:index];

	STAssertEquals(index, sut.currentItemIndex, @"Unexpected index");
	STAssertEquals([queue objectAtIndex:index], sut.currentItem, @"Unexpected item");
	STAssertTrue([sut hasPreviousItem], @"Should have previousItem");
	STAssertTrue([sut hasNextItem], @"Should have nextItem");
}

- (void)testSetQueueStart {
	[sut replaceQueue:queue startingAtIndex:0];
	
	STAssertEquals((NSUInteger)0, sut.currentItemIndex, @"Unexpected index");
	STAssertFalse([sut hasPreviousItem], @"Should not have previousItem");
	STAssertTrue([sut hasNextItem], @"Should have nextItem");
}

- (void)testSetQueueEnd {
	[sut replaceQueue:queue startingAtIndex:[queue count] - 1];
	
	STAssertEquals([queue count] - 1, sut.currentItemIndex, @"Unexpected index");
	STAssertTrue([sut hasPreviousItem], @"Should have previousItem");
	STAssertFalse([sut hasNextItem], @"Should not have nextItem");
}

- (void)testSkipToNextItem {
	[sut replaceQueue:queue startingAtIndex:[queue count] - 2];
	
	[sut skipToNextItem];

	STAssertEquals([queue count] - 1, sut.currentItemIndex, @"Unexpected index");
	STAssertTrue([sut hasPreviousItem], @"Should have previousItem");
	STAssertFalse([sut hasNextItem], @"Should not have nextItem");
}

- (void)testSkipToPreviousItem {
	[sut replaceQueue:queue startingAtIndex:1];
	
	[sut skipToPreviousItem];
	
	STAssertEquals((NSUInteger)0, sut.currentItemIndex, @"Unexpected index");
	STAssertFalse([sut hasPreviousItem], @"Should not have previousItem");
	STAssertTrue([sut hasNextItem], @"Should have nextItem");
}

- (void)testSetQueueShuffled {
	NSUInteger startIndex = 5;
	sut.shuffle = YES;
	
	[sut replaceQueue:queue startingAtIndex:startIndex];
	
	STAssertEquals((NSUInteger)0, sut.currentItemIndex, @"Unexpected index");
	STAssertEquals([queue objectAtIndex:startIndex], sut.currentItem, @"Unexpected item");
	STAssertFalse([sut hasPreviousItem], @"Should not have previousItem");
	STAssertTrue([sut hasNextItem], @"Should have nextItem");
}

- (void)testUnshuffleQueue {
	NSUInteger startIndex = 5;
	sut.shuffle = YES;
	[sut replaceQueue:queue startingAtIndex:startIndex];
	
	sut.shuffle = NO;
	
	STAssertEquals(startIndex, sut.currentItemIndex, @"Unexpected index");
	STAssertEquals([queue objectAtIndex:startIndex], sut.currentItem, @"Unexpected item");
	STAssertTrue([sut hasPreviousItem], @"Should have previousItem");
	STAssertTrue([sut hasNextItem], @"Should have nextItem");
}

- (void)testShuffleQueue {
	NSUInteger startIndex = 5;
	[sut replaceQueue:queue startingAtIndex:startIndex];

	sut.shuffle = YES;
	
	STAssertEquals((NSUInteger)0, sut.currentItemIndex, @"Unexpected index");
	STAssertEquals([queue objectAtIndex:startIndex], sut.currentItem, @"Unexpected item");
	STAssertFalse([sut hasPreviousItem], @"Should not have previousItem");
	STAssertTrue([sut hasNextItem], @"Should have nextItem");
}

- (void)testSkipToNextItemShuffled {
	sut.shuffle = YES;
	[sut replaceQueue:queue startingAtIndex:5];
	
	for(NSUInteger i = 1; i < [queue count]; ++i) {
		[sut skipToNextItem];
		STAssertEquals(i, sut.currentItemIndex, @"Unexpected index");
	}
	
	STAssertFalse([sut hasNextItem], @"Should have nextItem");
}

- (void)testSkipToNextItemAndBackShuffled {
	NSUInteger startIndex = 5;
	sut.shuffle = YES;
	[sut replaceQueue:queue startingAtIndex:startIndex];
	
	[sut skipToNextItem];
	[sut skipToPreviousItem];
	
	STAssertEquals((NSUInteger)0, sut.currentItemIndex, @"Unexpected index");
	STAssertEquals([queue objectAtIndex:startIndex], sut.currentItem, @"Unexpected item");
	STAssertFalse([sut hasPreviousItem], @"Should not have previousItem");
	STAssertTrue([sut hasNextItem], @"Should have nextItem");
}

- (void)testSetSingleItemQueueShuffled {
	NSArray *singleItemQueue = [queue subarrayWithRange:NSMakeRange(0, 1)];
	sut.shuffle = YES;

	[sut replaceQueue:singleItemQueue startingAtIndex:0];
	
	STAssertEquals((NSUInteger)0, sut.currentItemIndex, @"Unexpected index");
	STAssertEquals([queue objectAtIndex:0], sut.currentItem, @"Unexpected item");
	STAssertFalse([sut hasPreviousItem], @"Should not have previousItem");
	STAssertFalse([sut hasNextItem], @"Should not have nextItem");
}

- (void)testWithoutQueue {
	STAssertEquals((NSUInteger)NSNotFound, sut.currentItemIndex, @"Unexpected index");
	STAssertNil(sut.currentItem, @"Unexpected item");
	STAssertFalse([sut hasPreviousItem], @"Should not have previousItem");
	STAssertFalse([sut hasNextItem], @"Should not have nextItem");
}

- (void)testClearQueue {
	[sut replaceQueue:queue startingAtIndex:0];

	[sut clearQueue];
	
	STAssertEquals((NSUInteger)NSNotFound, sut.currentItemIndex, @"Unexpected index");
	STAssertNil(sut.currentItem, @"Unexpected item");
	STAssertFalse([sut hasPreviousItem], @"Should not have previousItem");
	STAssertFalse([sut hasNextItem], @"Should not have nextItem");
}

- (void)testNilQueue {
	[sut replaceQueue:queue startingAtIndex:0];
	
	[sut replaceQueue:nil startingAtIndex:25];
	
	STAssertEquals((NSUInteger)NSNotFound, sut.currentItemIndex, @"Unexpected index");
	STAssertNil(sut.currentItem, @"Unexpected item");
	STAssertFalse([sut hasPreviousItem], @"Should not have previousItem");
	STAssertFalse([sut hasNextItem], @"Should not have nextItem");
}

- (void)testEmptyQueue {
	[sut replaceQueue:[NSArray array] startingAtIndex:0];
	STAssertEquals((NSUInteger)NSNotFound, sut.currentItemIndex, @"Unexpected index");
	STAssertNil(sut.currentItem, @"invalid current item with empty queue");
	STAssertFalse([sut hasPreviousItem], @"Should not have previousItem");
	STAssertFalse([sut hasNextItem], @"Should not have nextItem");
}

@end

#import "SFPlaybackQueue.h"

#import "NSMutableArray+Shuffle.h"
#import "SFMediaItem.h"

@interface SFPlaybackQueue ()

@property (nonatomic, readwrite, strong) id currentItem;
@property (nonatomic, readwrite, assign) NSUInteger currentItemIndex;
@property (nonatomic, readwrite, strong) NSArray *queue;
@property (nonatomic, strong) NSArray *itemOrderIndices;

@end


@implementation SFPlaybackQueue

- (id)init {
    self = [super init];
    if (self) {
		self.currentItemIndex = NSNotFound;
    }
    return self;
}


@synthesize shuffle;
- (void)setShuffle:(BOOL)newShuffle {
	if(shuffle == newShuffle) {
		return;
	}
	shuffle = newShuffle;
	[self createItemOrderIndices];
}

@synthesize currentItem;
@synthesize currentItemIndex;
@synthesize queue;

@synthesize itemOrderIndices;

- (void)createItemOrderIndices {
	NSMutableArray *order = [NSMutableArray arrayWithCapacity:[self queueSize]];
	for(NSUInteger i = 0; i < [self queueSize]; ++i) {
		[order addObject:[NSNumber numberWithUnsignedInteger:i]];
	}

	if(self.shuffle && [self.queue count] > 1) {
		[order exchangeObjectAtIndex:0 withObjectAtIndex:[self.queue indexOfObject:self.currentItem]];
		[order shuffleRange:NSMakeRange(1, [order count] - 1)];
	}
	self.itemOrderIndices = order;
	self.currentItemIndex = [self indexForItem:self.currentItem];
}

- (NSUInteger)queueSize {
	return [queue count];
}

- (void)replaceQueue:(NSArray *)newQueue {
	if(self.shuffle) {
		[self replaceQueue:newQueue startingAtIndex:random() % [newQueue count]];
	}
	else {
		[self replaceQueue:newQueue startingAtIndex:0];
	}
}

- (void)replaceQueue:(NSArray *)newQueue startingAtIndex:(NSUInteger)index {
	self.queue = newQueue;
	if(newQueue.count == 0) {
		self.currentItem = nil;
		self.currentItemIndex = NSNotFound;
		return;
	}
	
	self.currentItem = [self.queue objectAtIndex:index];
	[self createItemOrderIndices];
}

- (void)clearQueue {
	self.queue = nil;
	self.currentItem = nil;
	[self createItemOrderIndices];
}

- (BOOL)hasNextItem {
	return self.currentItemIndex + 1 < [self queueSize];
}

- (BOOL)hasPreviousItem {
	return self.currentItemIndex > 0 && [self queueSize] > 0;
}

- (void)skipToNextItem {
	NSAssert([self hasNextItem], @"No more items");
	self.currentItemIndex = self.currentItemIndex + 1;
	[self updateCurrentItem];
}

- (void)skipToPreviousItem {
	NSAssert([self hasPreviousItem], @"No more items");
	self.currentItemIndex = self.currentItemIndex - 1;
	[self updateCurrentItem];
}

- (void)updateCurrentItem {
	self.currentItem = [self itemForIndex:self.currentItemIndex];
}
							 
- (id)itemForIndex:(NSUInteger)index {
	if(index == NSNotFound) {
		return nil;
	}
	return [self.queue objectAtIndex:[[self.itemOrderIndices objectAtIndex:index] unsignedIntegerValue]];
}

- (NSUInteger)indexForItem:(id)item {
	for(NSUInteger i = 0; i < [self queueSize]; ++i) {
		id<SFMediaItem> otherItem = [self itemForIndex:i];
		if(item == otherItem) {
			return i;
		}
	}
	return NSNotFound;
}

@end

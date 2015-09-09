//
//  CollectionWithChildren.m
//  Sonarflow
//
//  Created by Raphael Charwot on 02.03.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import "CollectionWithChildren.h"

@implementation CollectionWithChildren  {
	NSMutableArray *tempTracks;
	NSUInteger numTracks;
	
	NSArray *children;
}


- (NSMutableArray *)tempTracks {
	if(tempTracks == nil) {
		tempTracks = [[NSMutableArray alloc] init];
	}
	
	return tempTracks;
}

@synthesize numTracks;
- (NSUInteger)numTracks {
	return [tempTracks count] + numTracks;
}

@synthesize children;
- (void)setChildren:(NSArray *)newChildren {
	if(children == newChildren) {
		return;
	}
	
	children = newChildren;
	[self releaseLocalTracks];
}

- (void)addChildrenInMainThread:(NSArray *)newChildren {	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self insertChildren:newChildren atIndexes:nil];
	});
}

- (void)insertChildren:(NSArray *)newChildren atIndexes:(NSIndexSet *)indexes {
	NSAssert(indexes == nil, @"cannot accept indexes, need to sort on my own!");
	NSAssert(newChildren != nil, @"cannot insert nil children");
	
	NSArray *mergedChildren = [[NSSet setWithArray:[newChildren arrayByAddingObjectsFromArray:children]] allObjects];
	NSArray *sortedChildren = [self sortChildren:mergedChildren];
	self.children = sortedChildren;
}

- (id)init {
	if(self = [super init])	{
	}
	return self;
}


- (BOOL)mayHaveChildren {
	return YES;
}

- (BOOL)mayHaveImage {
	return NO;
}

- (UIImage *)image {
	return nil;
}

- (void)addTrack:(SFTrack *)track {
	[self.tempTracks addObject:track];
}

- (void)releaseLocalTracks {
	if(tempTracks != nil) {
		numTracks += [self.tempTracks count];
		tempTracks = nil;
	}
}

- (void)clearAllTracks {
	self.numTracks = 0;
	self.children = nil;
}

- (BOOL)hasReceivedAllTracks {
	return [tempTracks count] == numTracks;
}

- (NSArray *)tracks {
	if(tempTracks != nil) {
		return [self sortTracks:tempTracks];
	}
	
	NSMutableArray *childTracks = [NSMutableArray arrayWithCapacity:self.numTracks];
	for(NSObject<SFNativeMediaItem> *child in self.children) {
		NSAssert([child conformsToProtocol:@protocol(SFNativeMediaItem)], @"Child does not conform to HasTracks");
		[childTracks addObjectsFromArray:[child tracks]];
	}
	NSAssert([childTracks count] > 0, @"Both albums and tracks are nil");
	
	return childTracks;
}

- (id<SFMediaItem>)childWithKey:(id)childKey {
	SFMediaCollection *dummy = [[SFMediaCollection alloc] initWithKey:childKey];
	NSUInteger index = [children indexOfObject:dummy inSortedRange:NSMakeRange(0, [children count])
									   options:0 usingComparator:^NSComparisonResult(id obj1, id obj2) {
										   return [obj1 compareKeys:obj2];
									   }];

	if(index == NSNotFound) {
		return nil;
	}

	return [children objectAtIndex:index];
}

- (NSArray *)sortTracks:(NSArray *)tracks {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSArray *)sortChildren:(NSArray *)children {
	[self doesNotRecognizeSelector:_cmd];
	return nil;	
}



+ (NSSet *)keyPathsForValuesAffectingNumTracks {
	return [NSSet setWithObject:@"children"];
}

@end

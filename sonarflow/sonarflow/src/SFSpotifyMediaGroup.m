#import "SFSpotifyMediaGroup.h"

#import "SFObserver.h"

@interface SFSpotifyMediaGroup () <SFObserverDelegate>

@end


@implementation SFSpotifyMediaGroup {
	float duration;	
	NSMutableArray *children;
	NSMutableDictionary *sizeObserversByKey;
}

- (id)initWithName:(NSString *)theName key:(id)theKey player:(SFSpotifyPlayer *)thePlayer; {
    self = [super initWithName:theName key:theKey player:thePlayer];
    if (self) {
        sizeObserversByKey = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@synthesize children;
- (void)setChildren:(NSArray *)newChildren {
	if(children == newChildren) {
		return;
	}

	[sizeObserversByKey removeAllObjects];
	children = [newChildren mutableCopy];
	[self reparentChildren:children];
	[self updateSizeFromChildren];
	[self updateDurationFromChildren];
	[self addSizeObserversForChildren:children];
}
@synthesize size;

- (BOOL)mayHaveChildren {
	return YES;
}

- (NSNumber *)duration {
	return [NSNumber numberWithFloat:duration];
}

-(id<SFMediaItem>)childWithKey:childKey {
	for(id<SFMediaItem> item in children) {
		if([item.key isEqual:childKey]) {
			return item;
		}
	}
	
	return nil;
}

- (void)insertChildren:(NSArray *)newChildren atIndexes:(NSIndexSet *)indexes {
	[children insertObjects:newChildren atIndexes:indexes];
	[self reparentChildren:newChildren];
	[self updateSizeFromChildren];
	[self updateDurationFromChildren];
	[self addSizeObserversForChildren:newChildren];
}

- (void)removeChildrenAtIndexes:(NSIndexSet *)indexes {
	[self removeSizeObserversForChildren:[children objectsAtIndexes:indexes]];
    [children removeObjectsAtIndexes:indexes];
	[self updateSizeFromChildren];
	[self updateDurationFromChildren];
}

- (void)reparentChildren:(NSArray *)childrenToReparent {
	for(SFSpotifyMediaItem *child in childrenToReparent) {
		child.parent = self;
	}
}

- (void)updateSizeFromChildren {
	self.size = [[children valueForKeyPath:@"@sum.size"] unsignedIntegerValue];
}

- (void)updateDurationFromChildren {
	duration = [[children valueForKeyPath:@"@sum.duration"] floatValue];
}

- (void)addSizeObserversForChildren:(NSArray *)newChildren {
	for(SFSpotifyMediaItem *child in newChildren) {
		if(child.mayHaveChildren) {
			SFObserver *observer = [[SFObserver alloc] initWithObject:child keyPath:@"size" delegate:self];
			[sizeObserversByKey setObject:observer forKey:child.key];
		}
	}
}

- (void)removeSizeObserversForChildren:(NSArray *)oldChildren {
	for(SFSpotifyMediaItem *child in oldChildren) {
		[sizeObserversByKey removeObjectForKey:child.key];
	}
}

- (void)object:(NSObject *)object wasSetFrom:(id)oldValue to:(id)newValue {
	[self updateSizeFromChildren];
	[self updateDurationFromChildren];
}

- (NSArray *)tracks {
	if(self.children == nil) {
		return nil;
	}
	
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self.children count]];
	for(SFSpotifyMediaItem *child in self.children) {
		[result addObjectsFromArray:[child tracks]];
	}
	return result;
}

@end

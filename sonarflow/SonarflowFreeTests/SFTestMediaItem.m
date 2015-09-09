#import "SFTestMediaItem.h"

#import "SFMediaLibraryHelper.h"

@implementation SFTestMediaItem {
	NSMutableArray *children;
}

- (id)initWithKey:(id)theKey {
    self = [super init];
    if (self) {
		key = theKey;
		children = [[NSMutableArray alloc] init];
    }
    return self;
}

@synthesize key;
@synthesize name;
@synthesize children;
@synthesize parent;
@synthesize duration;
- (CGFloat)relativeSize {
	NSUInteger parentSize = [(SFTestMediaItem *) parent totalSize];
	if(parentSize == 0) {
		return 0;
	}
	return [self totalSize] / (CGFloat) parentSize;
}

- (NSUInteger)totalSize {
	if([self.children count] == 0) {
		return 1;
	}
	
	NSUInteger sum = 0;
	for(SFTestMediaItem *item in self.children) {
		sum += [item totalSize];
	}
	return sum;
}

- (BOOL)mayHaveChildren {
	return YES;
}

- (void)insertChildren:(NSArray *)newChildren atIndexes:(NSIndexSet *)indexes {
	[children insertObjects:newChildren atIndexes:indexes];
}

- (void)removeChildrenAtIndexes:(NSIndexSet *)indexes {
	[children removeObjectsAtIndexes:indexes];
}

- (id<SFMediaItem>)childWithKey:(id)childKey {
	return [SFMediaLibraryHelper mediaItemForKey:childKey inArray:self.children];
}

- (BOOL)showAsBubble {
	return YES;
}

- (BOOL)hasDetailViewController {
	return NO;
}

- (BOOL)mayHaveImage {
	return NO;
}

- (void)startPlayback {
}

- (NSArray *)keyPath {
	return [[self.parent keyPath] arrayByAddingObject:self.key];
}

- (SFTestMediaItem *)addChildWithKey:(id)aKey {
	SFTestMediaItem *child = [[SFTestMediaItem alloc] initWithKey:aKey];
	[self addChild:child];
	return child;
}

- (void)addChild:(SFTestMediaItem *)child {
	child.parent = self;
	[self insertChildren:@[child] atIndexes:[NSIndexSet indexSetWithIndex:[children count]]];
}

- (void)removeChild:(SFTestMediaItem *)child {
	[self removeChildrenAtIndexes:[NSIndexSet indexSetWithIndex:[children indexOfObject:child]]];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ with KeyPath %@", [self class], [self keyPath]];
}

@end

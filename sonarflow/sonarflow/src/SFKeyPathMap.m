#import "SFKeyPathMap.h"

#import "NSArray+StartsWith.h"
#import "NSArray+KeyPath.h"

@interface SFKeyPathEntry : NSObject

@property (nonatomic, strong) id object;
@property (nonatomic, readonly) NSMutableDictionary *childrenByKey;

- (SFKeyPathEntry *)entryForKeyPath:(NSArray *)keyPath;
- (void)setEntry:(SFKeyPathEntry *)entry forKeyPath:(NSArray *)keyPath;
- (void)removeChildren;

@end

@implementation SFKeyPathEntry

@synthesize object;
@synthesize childrenByKey;

- (id)init {
    self = [super init];
    if (self) {
		childrenByKey = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)entryForKeyPath:(NSArray *)keyPath {
	if([keyPath count] == 0) {
		return self;
	}
	
	return [[childrenByKey objectForKey:[keyPath head]] entryForKeyPath:[keyPath tail]];
}

- (void)setEntry:(SFKeyPathEntry *)entry forKeyPath:(NSArray *)keyPath {
	if([keyPath count] == 1) {
		[childrenByKey setObject:entry forKey:[keyPath head]];
	}
	else {
		[[childrenByKey objectForKey:[keyPath head]] setEntry:entry forKeyPath:[keyPath tail]];
	}
}

- (void)removeChildren {
	[childrenByKey removeAllObjects];
}

@end

@implementation SFKeyPathMap {
	SFKeyPathEntry *rootEntry;
}

- (id)init {
    self = [super init];
    if (self) {
		rootEntry = [[SFKeyPathEntry alloc] init];
    }
    return self;
}

- (id)objectForKeyPath:(NSArray *)keyPath {
	return [rootEntry entryForKeyPath:keyPath].object;
}

- (void)setObject:(id)object forKeyPath:(NSArray *)keyPath {
	SFKeyPathEntry *entry = [rootEntry entryForKeyPath:keyPath];
	if(entry == nil) {
		entry = [[SFKeyPathEntry alloc] init];
		[rootEntry setEntry:entry forKeyPath:keyPath];
	}
	
	entry.object = object;
}

- (void)removeObjectsForKeyPath:(NSArray *)keyPath {
	SFKeyPathEntry *entry = [rootEntry entryForKeyPath:keyPath];
	entry.object = nil;
	[entry removeChildren];
}

- (void)removeChildrenOfKeyPath:(NSArray *)keyPath {
	SFKeyPathEntry *entry = [rootEntry entryForKeyPath:keyPath];
	[entry removeChildren];
}

- (void)removeAllObjects {
	rootEntry = [[SFKeyPathEntry alloc] init];
}

@end

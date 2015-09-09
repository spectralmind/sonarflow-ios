#import "SFAbstractMediaItemComposite.h"

@interface SFAbstractMediaItemComposite ()

@property (nonatomic, readwrite, strong) NSArray *children;

- (void)tryGetChildren;

@end

@implementation SFAbstractMediaItemComposite {
	NSString *name;
	NSArray *mediaItems;
}

- (id)initWithName:(NSString *)theName mediaItems:(NSArray *)theMediaItems {
	if(self = [super init]) {
		name = theName;
		mediaItems = theMediaItems;

		for(NSObject<SFMediaItem> *child in mediaItems) {
			[child addObserver:self forKeyPath:@"children" options:0 context:nil];
		}

		[self tryGetChildren];
	}
	return self;
}

- (void)dealloc {
	for(NSObject<SFMediaItem> *child in mediaItems) {
		[child removeObserver:self forKeyPath:@"children"];
	}
}

@synthesize showArtists;
@synthesize name;
@synthesize children;
@synthesize mediaItems;

- (void)tryGetChildren {
	NSUInteger count = 0;
	for(id<SFMediaItem> child in mediaItems) {
		if([child mayHaveChildren] && child.children == nil) {
			return;
		}
		
		count += [child.children count];
	}
	
	NSMutableArray *combinedChildren = [[NSMutableArray alloc] initWithCapacity:count];
	//All are loaded, we can finally continue
	for(id<SFMediaItem> child in mediaItems) {
		[combinedChildren addObjectsFromArray:[child children]];
	}
	
	self.children = combinedChildren;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if([keyPath isEqualToString:@"children"]) {
		[self tryGetChildren];
	}
	else if([[self superclass] instancesRespondToSelector:@selector(observeValueForKeyPath:ofObject:change:context:)]) {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (id)key {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id<SFMediaItem>)parent {
	return nil;
}

- (NSNumber *)duration {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (BOOL)mayHaveChildren {
	return YES;
}

- (BOOL)showAsBubble {
	return NO;
}

- (BOOL)hasDetailViewController {
	return YES;
}

- (BOOL)mayHaveImage {
	return NO;
}

- (NSArray *)keyPath {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (void)startPlayback {
	[self doesNotRecognizeSelector:_cmd];
}

@end

#import "SFAbstractDiscoveredArtist.h"

#import "RootKey.h"
#import "MediaViewControllerFactory.h"

@interface SFAbstractDiscoveredArtist ()

@end

@implementation SFAbstractDiscoveredArtist {
	RootKey *key;
	NSString *name;
}

-(id)initWithKey:(RootKey *)theKey name:(NSString *)theName {
	self = [super init];
	if(self == nil) {
		return nil;
	}
	
	key = theKey;
	name = theName;
	
	return self;
}


@synthesize key;
@synthesize name;

- (NSArray *)children {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id<SFMediaItem>)parent {
	return nil;
}

- (NSNumber *)duration {
	return [NSNumber numberWithFloat:0.0];
}

- (BOOL)mayHaveImage {
	return NO;
}

- (BOOL)mayHaveChildren {
	return NO;
}

- (BOOL)showAsBubble {
	return NO;
}

- (UIColor *)bubbleColor {
	return nil;
}

- (CGFloat)relativeSize {
	return 1.0;
}

- (BOOL)hasDetailViewController {
	return YES;
}

- (UIViewController *)createDetailViewControllerWithFactory:(MediaViewControllerFactory *)factory {
	return [factory viewControllerForDiscoveredArtist:self];
}

- (void)startPlayback {
	[self doesNotRecognizeSelector:_cmd];
}

- (void)startPlaybackAtChildIndex:(NSUInteger)childIndex {
	[self doesNotRecognizeSelector:_cmd];
}

-(NSArray *)keyPath {
	return [NSArray arrayWithObject:key];
}

- (NSString *)artistNameForDiscovery {
	return [self name];
}

@end

#import "SFObserver.h"

@implementation SFObserver {
	NSObject *object;
	NSString *keyPath;
	id<SFObserverDelegate> __weak delegate;
}

- (id)initWithObject:(NSObject *)theObject keyPath:(NSString *)theKeyPath delegate:(id<SFObserverDelegate>)theDelegate {
    self = [super init];
    if (self) {
		object = theObject;
		keyPath = theKeyPath;
		delegate = theDelegate;
		[object addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)dealloc {
	[object removeObserver:self forKeyPath:keyPath];
}

@synthesize object;
@synthesize delegate;

- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)aObject change:(NSDictionary *)change context:(void *)context {
	NSKeyValueChange changeKind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
	id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
	id newValue = [change objectForKey:NSKeyValueChangeNewKey];
	if([oldValue isKindOfClass:[NSNull class]]) {
		oldValue = nil;
	}
	if([newValue isKindOfClass:[NSNull class]]) {
		newValue = nil;
	}
	[self handleChange:change ofKind:changeKind from:oldValue to:newValue];
}

- (void)handleChange:(NSDictionary *)change ofKind:(NSKeyValueChange)changeKind from:(id)oldValue to:(id)newValue {
	NSAssert(changeKind == NSKeyValueChangeSetting, @"Invalid change kind");
	if([delegate respondsToSelector:@selector(object:wasSetFrom:to:)]) {
		[delegate object:object wasSetFrom:oldValue to:newValue];
	}
}

@end

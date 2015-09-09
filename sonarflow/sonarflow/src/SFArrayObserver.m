#import "SFArrayObserver.h"

@implementation SFArrayObserver {
}

- (id)initWithObject:(NSObject *)theObject keyPath:(NSString *)theKeyPath delegate:(id<SFArrayObserverDelegate>)theDelegate {
    self = [super initWithObject:theObject keyPath:theKeyPath delegate:theDelegate];
    if (self) {
    }
    return self;
}

- (void)handleChange:(NSDictionary *)change ofKind:(NSKeyValueChange)changeKind from:(id)oldValue to:(id)newValue {
	if(changeKind == NSKeyValueChangeSetting) {
		[super handleChange:change ofKind:changeKind from:oldValue to:newValue];
	}
	else {
		NSIndexSet *changedIndices = [change objectForKey:NSKeyValueChangeIndexesKey];
		id<SFArrayObserverDelegate> arrayDelegate = (id<SFArrayObserverDelegate>)self.delegate;
		if(changeKind == NSKeyValueChangeRemoval &&
		   [arrayDelegate respondsToSelector:@selector(objects:wereDeletedAtIndexes:ofObject:)]) {
			[arrayDelegate objects:oldValue wereDeletedAtIndexes:changedIndices ofObject:self.object];
		}
		else if(changeKind == NSKeyValueChangeReplacement &&
				[arrayDelegate respondsToSelector:@selector(objects:wereReplacedWithObjects:atIndexes:ofObject:)]) {
			[arrayDelegate objects:oldValue wereReplacedWithObjects:newValue atIndexes:changedIndices ofObject:self.object];
		}
		else if(changeKind == NSKeyValueChangeInsertion &&
				[arrayDelegate respondsToSelector:@selector(objects:wereInsertedAtIndexes:ofObject:)]) {
			[arrayDelegate objects:newValue wereInsertedAtIndexes:changedIndices ofObject:self.object];
		}
	}
}


@end

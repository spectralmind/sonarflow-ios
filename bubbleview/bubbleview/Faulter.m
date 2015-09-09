#import "Faulter.h"

#define kFaultDelay 0.5

@interface Faulter ()

@property (nonatomic, strong) NSDate *faultDelayStart;

- (void)turnIntoFault;

@end


@implementation Faulter

- (id)initWithRealizeBlock:(RealizeBlock)theRealizeBlock faultBlock:(FaultBlock)theFaultBlock {
    self = [super init];
    if (self) {
        realizeBlock = [theRealizeBlock copy];
		faultBlock = [theFaultBlock copy];
    }
    return self;
}

- (void)dealloc {
	[self turnIntoFault];
}

@synthesize faultDelayStart;

- (void)turnIntoFault {
	faultBlock(element);
	element = nil;
}

- (id)element {
	if(element == nil && isRealizing == NO) {
		isRealizing = YES;
		element = realizeBlock();
		isRealizing = NO;
	}

	self.faultDelayStart = nil;

	return element;
}

- (BOOL)isFault {
	return element == nil;
}

- (BOOL)couldBecomeFault {
	return self.faultDelayStart != nil;
}

- (void)allowFaulting {
	if(element != nil) {
		if(self.faultDelayStart == nil) {
			self.faultDelayStart = [NSDate date];
		}
		else if([self.faultDelayStart timeIntervalSinceNow] < -kFaultDelay) {
			[self turnIntoFault];
		}
	}
}

@end

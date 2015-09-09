#import "CoalescingDispatcher.h"

@interface CoalescingDispatcher ()

@property (nonatomic, weak) NSTimer *timer;

@end


@implementation CoalescingDispatcher{
	NSTimeInterval period;
	CoalescedBlock block;
}

- (id)initWithPeriod:(NSTimeInterval)thePeriod block:(CoalescedBlock)theBlock {
    self = [super init];
    if (self) {
		period = thePeriod;
		block = [theBlock copy];
    }
    return self;
}


- (void)setTimer:(NSTimer *)newTimer {
	if(_timer == newTimer) {
		return;
	}

	[_timer invalidate];
	_timer = newTimer;
}

- (void)fireAfterPeriod {
	self.timer = [NSTimer scheduledTimerWithTimeInterval:period target:self selector:@selector(delayTimerFired:) userInfo:nil repeats:NO];
}

- (void)delayTimerFired:(NSTimer*)theTimer {
	self.timer = nil;
	block();
}

@end

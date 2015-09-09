#import "SFTimeTracker.h"

@interface SFTimeTracker ()

@property (nonatomic, strong) NSDate *currentStartDate;

@end


@implementation SFTimeTracker {
	BOOL active;
	NSTimeInterval previousDuration;
	NSDate *currentStartDate;
}


@synthesize currentStartDate;

- (void)setActive:(BOOL)newActive {
	if(active == newActive) {
		return;
	}
	active = newActive;
	[self updateDuration];
}

- (BOOL)isActive {
	return active;
}

- (void)reset {
	previousDuration = 0;
	self.currentStartDate = nil;
	[self updateDuration];
}

- (void)updateDuration {
	previousDuration += -[self.currentStartDate timeIntervalSinceNow];
	if(active) {
		self.currentStartDate = [NSDate date];
	}
	else {
		self.currentStartDate = nil;
	}
}

- (NSTimeInterval)duration {
	return previousDuration + -[self.currentStartDate timeIntervalSinceNow];
}

@end

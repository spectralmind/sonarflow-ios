#import "AppStatusObserver.h"

@interface AppStatusObserver ()

- (void)observeAppState;
- (void)willResignActive:(NSNotification *)notification;
- (void)didEnterBackground:(NSNotification *)notification;
- (void)willEnterForeground:(NSNotification *)notification;
- (void)didBecomeActive:(NSNotification *)notification;
- (void)becomeActiveTimerFired:(NSTimer *)timer;
- (void)appDidBecomeActive;

@end


@implementation AppStatusObserver {
	NSTimeInterval becomeActiveDelay;
	NSTimer *becomeActiveTimer;
}

- (id)init {
	return [self initWithBecomeActiveDelay:0];
}

- (id)initWithBecomeActiveDelay:(NSTimeInterval)delay {
	self = [super init];
	if(self) {
		becomeActiveDelay = delay;
		[self observeAppState];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeAppState {
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

	[notificationCenter addObserver:self
						   selector:@selector(willResignActive:)
							   name:UIApplicationWillResignActiveNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(didBecomeActive:)
							   name:UIApplicationDidBecomeActiveNotification
							 object:nil];
	
	if([[UIApplication sharedApplication] respondsToSelector:@selector(backgroundTimeRemaining)]) {
		[notificationCenter addObserver:self
							   selector:@selector(didEnterBackground:)
								   name:UIApplicationDidEnterBackgroundNotification
								 object:nil];
		[notificationCenter addObserver:self
							   selector:@selector(willEnterForeground:)
								   name:UIApplicationWillEnterForegroundNotification
								 object:nil];
	}
}

- (void)willResignActive:(NSNotification *)notification {
	[becomeActiveTimer invalidate];
	becomeActiveTimer = nil;
	
	if([self.delegate respondsToSelector:@selector(appWillResignActive)]) {
		[self.delegate appWillResignActive];
	}
}

- (void)didEnterBackground:(NSNotification *)notification {
	if([self.delegate respondsToSelector:@selector(appDidEnterBackground)]) {
		[self.delegate appDidEnterBackground];
	}
}

- (void)willEnterForeground:(NSNotification *)notification {
	if([self.delegate respondsToSelector:@selector(appWillEnterForeground)]) {
		[self.delegate appWillEnterForeground];
	}
}

- (void)didBecomeActive:(NSNotification *)notification {
	if(becomeActiveDelay > 0) {
		[becomeActiveTimer invalidate];
		becomeActiveTimer = [NSTimer scheduledTimerWithTimeInterval:becomeActiveDelay
															 target:self
														   selector:@selector(becomeActiveTimerFired:)
														   userInfo:nil
															repeats:NO];
	}
	else {
		[self appDidBecomeActive];
	}
}

- (void)becomeActiveTimerFired:(NSTimer *)timer {
	becomeActiveTimer = nil;
	[self appDidBecomeActive];
}

- (void)appDidBecomeActive {
	if([self.delegate respondsToSelector:@selector(appDidBecomeActive)]) {
		[self.delegate appDidBecomeActive];
	}
}

@end

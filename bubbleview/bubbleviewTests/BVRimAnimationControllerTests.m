#import "BVRimAnimationControllerTests.h"

#import <OCMock/OCMock.h>
#import "BVRimAnimationController.h"
#import "BVRimAnimationControllerDelegate.h"
#import "BubbleView.h"

static const NSTimeInterval kEpsilon = 0.001f;
static const NSString *kFirst = @"First";
static const NSString *kSecond = @"Second";
static const NSString *kThird = @"Thrid";

@implementation BVRimAnimationControllerTests {
	BVRimAnimationController *sut;
	id delegateMock;
}

- (void)setUp {
	delegateMock = [OCMockObject mockForProtocol:@protocol(BVRimAnimationControllerDelegate)];
	[[[delegateMock stub] andReturn:[NSArray array]] visibleBubbleViewsInKeyPath:nil];
	
	sut = [[BVRimAnimationController alloc] init];
}

- (void)tearDown {
	[delegateMock verify];
}

- (NSArray *)testKeyPath {
	return [NSArray arrayWithObject:@"Foo"];
}

- (void)testNoProgressAfterInit {
	NSTimeInterval elapsed = [self elapsedAnimationTimeAfterSeconds:0.1];

	STAssertEqualsWithAccuracy(0.0, elapsed, kEpsilon, @"Should make no progress");
}

- (void)testNoProgressWithoutKeyPath {
	sut.keyPath = nil;
	sut.state = BVRimAnimationStatePlaying;
	
	NSTimeInterval elapsed = [self elapsedAnimationTimeAfterSeconds:0.1];
	
	STAssertEqualsWithAccuracy(0.0, elapsed, kEpsilon, @"Should make no progress");
}

- (void)testNoProgressWhenPaused {
	sut.keyPath = [self testKeyPath];
	sut.state = BVRimAnimationStatePaused;
	
	NSTimeInterval elapsed = [self elapsedAnimationTimeAfterSeconds:0.1];
	
	STAssertEqualsWithAccuracy(0.0, elapsed, kEpsilon, @"Should make no progress");
}

- (void)testMakesProgressWhenPlaying {
	sut.keyPath = [self testKeyPath];
	sut.state = BVRimAnimationStatePlaying;
	
	NSTimeInterval elapsed = [self elapsedAnimationTimeAfterSeconds:0.1];
	
	STAssertTrue(elapsed > kEpsilon, @"Should make progress");
}

- (void)testKeepsProgressWhenPaused {
	sut.state = BVRimAnimationStatePlaying;
	sut.keyPath = [self testKeyPath];
	STAssertTrue([self elapsedAnimationTimeAfterSeconds:0.1] > kEpsilon, @"Should make progress");
	
	NSTimeInterval firstDuration = [sut currentAnimationPlayDuration];
	[self elapsedAnimationTimeAfterSeconds:0.1];
	sut.state = BVRimAnimationStatePaused;
	NSTimeInterval elapsed = [self elapsedAnimationTimeAfterSeconds:0.1];
	NSTimeInterval secondDuration = [sut currentAnimationPlayDuration];
	
	STAssertEqualsWithAccuracy(0.0, elapsed, kEpsilon, @"Should make no progress");
	STAssertTrue(secondDuration - firstDuration > kEpsilon, @"Should keep progress");
}

- (void)testKeepsProgressWhenPausedAndPlayingAgain {
	sut.state = BVRimAnimationStatePlaying;
	sut.keyPath = [self testKeyPath];
	STAssertTrue([self elapsedAnimationTimeAfterSeconds:0.1] > kEpsilon, @"Should make progress");
	
	NSTimeInterval firstDuration = [sut currentAnimationPlayDuration];
	sut.state = BVRimAnimationStatePaused;
	sut.state = BVRimAnimationStatePlaying;
	NSTimeInterval elapsed = [self elapsedAnimationTimeAfterSeconds:0.1];
	NSTimeInterval secondDuration = [sut currentAnimationPlayDuration];
	
	STAssertTrue(elapsed > kEpsilon, @"Should make progress");
	STAssertTrue(secondDuration - firstDuration > kEpsilon, @"Should keep progress");
}

- (void)testShouldNotHaveRimAnimationWithNilKeyPath {
	sut.keyPath = nil;
	
	STAssertFalse([sut shouldHaveRimAnimation:[NSArray arrayWithObject:kFirst]], @"Should not have rim animation");
}

- (void)testShouldHaveRimAnimation {
	NSArray *keyPath = [NSArray arrayWithObjects:kFirst, kSecond, kThird, nil];
	NSArray *subKeyPath1 = [NSArray arrayWithObject:kFirst];
	NSArray *subKeyPath2 = [NSArray arrayWithObjects:kFirst, kSecond, nil];
	NSArray *otherKeyPath = [NSArray arrayWithObjects:kSecond, kThird, nil];
	NSArray *longerKeyPath = [NSArray arrayWithObjects:kFirst, kSecond, kThird, @"Foo", nil];
	
	sut.keyPath = keyPath;
	
	STAssertTrue([sut shouldHaveRimAnimation:keyPath], @"Should have rim animation");
	STAssertTrue([sut shouldHaveRimAnimation:subKeyPath1], @"Should have rim animation");
	STAssertTrue([sut shouldHaveRimAnimation:subKeyPath2], @"Should have rim animation");
	STAssertTrue([sut shouldHaveRimAnimation:longerKeyPath], @"Should have rim animation");
	STAssertFalse([sut shouldHaveRimAnimation:otherKeyPath], @"Should not have rim animation");	
}

//Can't write any useful test for the view interaction because OCMock does not support "any float" stubbing (for the NSTimeInterval offset).
//- (void)testSetKeyPathUpdateView {
//	id viewMock = [self newViewMock];
//	[[viewMock expect] setRimAnimationState:BVRimAnimationStatePaused offset:0.0f];
//	[[[delegateMock expect] andReturn:[NSArray arrayWithObject:viewMock]] visibleBubbleViewsInKeyPath:[self testKeyPath]];
//	sut.delegate = delegateMock;
//	
//	sut.keyPath = [self testKeyPath];
//	
//	[viewMock verify];
//}
//
//- (id)newViewMock {
//	return nil;
//}

- (NSTimeInterval)elapsedAnimationTimeAfterSeconds:(NSTimeInterval)duration {
	NSTimeInterval firstDuration = [sut currentAnimationPlayDuration];
	[NSThread sleepForTimeInterval:duration];
	NSTimeInterval secondDuration = [sut currentAnimationPlayDuration];
	return secondDuration - firstDuration;
}

@end

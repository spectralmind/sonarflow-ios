//
//  TrackComparatorTests.m
//  sonarflow
//
//  Created by Raphael Charwot on 09.09.11.
//  Copyright (c) 2011 Charwot. All rights reserved.
//

#import "TrackComparatorTests.h"
#import "TrackComparator.h"
#import <OCMock/OCMock.h>
#import "SFTrack.h"
#import "SFNativeTrack.h"

@implementation TrackComparatorTests

- (id)trackMockWithId:(NSNumber *)mediaItemId {
	id mock = [OCMockObject mockForProtocol:@protocol(SFNativeTrack)];
	[[[mock stub] andReturn:mediaItemId] mediaItemId];
	return mock;
}

- (void)testTrackComparisionEquality {
	NSNumber *mediaItemId = [NSNumber numberWithLongLong:1234];
	id firstMock = [self trackMockWithId:mediaItemId];
	id secondMock = [self trackMockWithId:mediaItemId];
	
	BOOL result = [TrackComparator isTrack:firstMock equalToTrack:secondMock];
	
	STAssertTrue(result, @"Should be equal");
}

- (void)testTrackComparisionInequality {
	id firstMock = [self trackMockWithId:[NSNumber numberWithLongLong:1234]];
	id secondMock = [self trackMockWithId:[NSNumber numberWithLongLong:12345]];
	
	BOOL result = [TrackComparator isTrack:firstMock equalToTrack:secondMock];
	
	STAssertFalse(result, @"Should not be equal");
}

- (void)testTrackComparisionInequality2 {
	id firstMock = [self trackMockWithId:[NSNumber numberWithLongLong:-1234]];
	id secondMock = [self trackMockWithId:[NSNumber numberWithLongLong:1234]];
	
	BOOL result = [TrackComparator isTrack:firstMock equalToTrack:secondMock];
	
	STAssertFalse(result, @"Should not be equal");
}

//CoreData has no way of storing unsigned long longs
//therefore the track IDs are stored as signed long longs,
//but should still be equal to the original unsigned IDs after loading.
//This is a simpilfied test with real-world observed numbers to avoid
//the overhead of creating a persistence context, etc. in this test
- (void)testTrackComparisionWithSignIssue {
	long long firstId = -7402305261211772261;
	unsigned long long secondId = 11044438812497779355u;
	NSNumber *firstMediaItemId = [NSNumber numberWithLongLong:firstId];
	NSNumber *secondMediaItemId = [NSNumber numberWithUnsignedLongLong:secondId];
	id firstMock = [self trackMockWithId:firstMediaItemId];
	id secondMock = [self trackMockWithId:secondMediaItemId];
	
	BOOL result = [TrackComparator isTrack:firstMock equalToTrack:secondMock];

	STAssertTrue(result, @"Should be equal");
}

- (void)testTrackComparisionNilInequality {
	id trackMock = [self trackMockWithId:[NSNumber numberWithLongLong:12345]];
	
	BOOL result = [TrackComparator isTrack:nil equalToTrack:trackMock];
	
	STAssertFalse(result, @"Should not be equal");
}

- (void)testTrackComparisionNilInequality2 {
	id trackMock = [self trackMockWithId:[NSNumber numberWithLongLong:12345]];
	
	BOOL result;
	STAssertNoThrow(result = [TrackComparator isTrack:trackMock equalToTrack:nil], @"Should not throw");
	
	STAssertFalse(result, @"Should not be equal");
}

- (void)testTrackComparisionNilEquality {
	
	BOOL result = [TrackComparator isTrack:nil equalToTrack:nil];
	
	STAssertTrue(result, @"Should be equal");
}

@end

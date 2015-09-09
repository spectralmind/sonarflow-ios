//
//  SMResultCacheTests.m
//  SMArtist
//
//  Created by Raphael Charwot on 16.02.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "SMResultCacheTests.h"
#import "SMResultCache.h"
#import "SMArtistResult.h"
#import "SMArtistResult+Private.h"
#import "SMSingleArtistRequest.h"

@implementation SMResultCacheTests


- (void)setUp {
	
}

- (SMResultCache *)newSutWithMaximumAge:(NSTimeInterval)maximumAge {
	SMResultCache *sut = [[SMResultCache alloc] initWithMaximumAge:maximumAge];
	[sut clear];
	
	return sut;
}

- (void)testUnknownResultFromCache {
	NSString *testCacheId = @"Cac5/44$$:#he-Me-4834";
	SMResultCache *sut = [self newSutWithMaximumAge:10.0];
	
	SMArtistResult *result = [sut resultForCacheId:testCacheId];
	
	STAssertNil(result, @"Should not contain an uncached element");
}

- (void)testResultFromCache {
	NSString *testCacheId = @"Cac5/44$$:#he-Me-4834";
	SMResultCache *sut = [self newSutWithMaximumAge:10.0];

	SMArtistResult *originalResult = [[SMArtistResult alloc] init];
	originalResult.recognizedArtistName = @"Great artist";
	
	[sut storeResult:originalResult forCacheId:testCacheId];
	SMArtistResult *result = [sut resultForCacheId:testCacheId];
	
	STAssertEqualObjects(originalResult.recognizedArtistName, result.recognizedArtistName, @"Should return cached element");
}

- (void)testOverwrite {
	SMResultCache *sut = [self newSutWithMaximumAge:10.0];
	NSString *testCacheId = @"Cac5/44ü$:#he-Mä-48\\34";

	SMArtistResult *firstResult = [[SMArtistResult alloc] init];
	firstResult.recognizedArtistName = @"Great artist";
	[sut storeResult:firstResult forCacheId:testCacheId];
	
	SMArtistResult *secondResult = [[SMArtistResult alloc] init];
	secondResult.recognizedArtistName = @"Greater artist";
	[sut storeResult:secondResult forCacheId:testCacheId];

	SMArtistResult *result = [sut resultForCacheId:testCacheId];
	
	STAssertEqualObjects(secondResult.recognizedArtistName, result.recognizedArtistName, @"Should return newer element");

}

- (void)testCacheEvictionAfterTimeout {
	SMResultCache *sut = [self newSutWithMaximumAge:0.0];
	NSString *testCacheId = @"Cac5/44ü$:#he-Mä-48\\34";

	SMArtistResult *firstResult = [[SMArtistResult alloc] init];
	firstResult.recognizedArtistName = @"Great artist";
	[sut storeResult:firstResult forCacheId:testCacheId];
	
	[sut pruneExpired];
	
	SMArtistResult *result = [sut resultForCacheId:testCacheId];
	
	STAssertNil(result, @"Should not contain expired element");
}

- (void)testCacheDoesNotReturnExpiredObjects {
	SMResultCache *sut = [self newSutWithMaximumAge:0.0];
	NSString *testCacheId = @"Cac5/44ü$:#he-Mä-48\\34";
	
	SMArtistResult *firstResult = [[SMArtistResult alloc] init];
	firstResult.recognizedArtistName = @"Great artist";
	[sut storeResult:firstResult forCacheId:testCacheId];
		
	SMArtistResult *result = [sut resultForCacheId:testCacheId];
	
	STAssertNil(result, @"Should not contain expired element");
	
}

- (void)testNoCacheEvictionBeforeTimeout {
	SMResultCache *sut = [self newSutWithMaximumAge:10000.0];
	NSString *testCacheId = @"Cac5/44ü$:#he-Mä-48\\34";
	
	SMArtistResult *cachedResult = [[SMArtistResult alloc] init];
	cachedResult.recognizedArtistName = @"Great artist";
	[sut storeResult:cachedResult forCacheId:testCacheId];
	
	[sut pruneExpired];
	
	SMArtistResult *result = [sut resultForCacheId:testCacheId];
	
	STAssertEqualObjects(cachedResult.recognizedArtistName, result.recognizedArtistName, @"Should not have evicted element");
}

- (void)testCacheReturnsExpiredResultWhenRequested {
	SMResultCache *sut = [self newSutWithMaximumAge:0.0];
	NSString *testCacheId = @"Cac5/44ü$:#he-Mä-48\\34";
	
	SMArtistResult *cachedResult = [[SMArtistResult alloc] init];
	cachedResult.recognizedArtistName = @"Great artist";
	[sut storeResult:cachedResult forCacheId:testCacheId];
		
	SMArtistResult *result = [sut resultForCacheId:testCacheId allowExpired:YES];
	
	STAssertEqualObjects(cachedResult.recognizedArtistName, result.recognizedArtistName, @"Should return expired element");	
}

@end

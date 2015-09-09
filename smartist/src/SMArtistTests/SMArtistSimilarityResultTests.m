//
//  SMArtistSimilarityResultTests.m
//  SMArtist
//
//  Created by Raphael Charwot on 08.02.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "SMArtistSimilarityResultTests.h"
#import "SMArtistSimilarityResult.h"
#import "SMArtistResult+Private.h"

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMock/OCMock.h>

@implementation SMArtistSimilarityResultTests {
	SMSimilarArtist *item1;
	SMSimilarArtist *item2;
	SMArtistSimilarityResult *result1;
	SMArtistSimilarityResult *result2;
	NSArray *results;
}

- (void)setUp {
	item1 = [self itemWithName:@"SomeName"];
	item2 = [self itemWithName:@"SomeName2"];
	result1 = [self resultWithItem:item1];
	result2 = [self resultWithItem:item2];
	results = [NSArray arrayWithObjects:result1, result2, nil];
}

- (void)tearDown {
}

- (SMSimilarArtist *)itemWithName:(NSString *)name {
	return [SMSimilarArtist similarArtistWithName:name withMatchValue:0];
}

- (SMArtistSimilarityResult *)resultWithItem:(SMSimilarArtist *)item {
	SMArtistSimilarityResult *result = [[SMArtistSimilarityResult alloc] init];
	result.similarArtists = [NSArray arrayWithObject:item];
	return result;
}

- (SMArtistSimilarityResult *)resultWithError {
	SMArtistSimilarityResult *result = [[SMArtistSimilarityResult alloc] init];
	result.error = [NSError errorWithDomain:@"SMArtist" code:100 userInfo:nil];
	return result;
}

- (void)assertExpectedItems:(NSSet *)expectedItems cacheable:(BOOL)cacheable error:(BOOL)error sut:(SMArtistSimilarityResult *)sut {
	STAssertEquals([expectedItems count], [sut.similarArtists count], @"Unexpected number of items");
	STAssertEqualObjects(expectedItems, [NSSet setWithArray:sut.similarArtists], @"Unexpected items");
	STAssertEquals(cacheable, sut.cacheable, @"Unexpected value for cacheable");
	STAssertEquals(error, (BOOL)(sut.error != nil), @"Unexpected value for error");
}

- (void)testMergeResults {
	
	SMArtistSimilarityResult *sut = [[SMArtistSimilarityResult alloc] initWithResults:results];
	
	NSSet *expectedItems = [NSSet setWithObjects:item1, item2, nil];
	[self assertExpectedItems:expectedItems cacheable:YES error:NO sut:sut];
}

- (void)testMergeSameResults {
	result2.similarArtists = [NSArray arrayWithObjects:item2, item1, nil];
	
	SMArtistSimilarityResult *sut = [[SMArtistSimilarityResult alloc] initWithResults:results];
	
	NSSet *expectedItems = [NSSet setWithObjects:item1, item2, nil];
	[self assertExpectedItems:expectedItems cacheable:YES error:NO sut:sut];
}

- (void)testMergeNonCacheableResults {
	result1.cacheable = NO;
	
	SMArtistSimilarityResult *sut = [[SMArtistSimilarityResult alloc] initWithResults:results];
	
	NSSet *expectedItems = [NSSet setWithObjects:item1, item2, nil];
	[self assertExpectedItems:expectedItems cacheable:NO error:NO sut:sut];
}

- (void)testMergeResultsWithError {
	result2 = [self resultWithError];
	results = [NSArray arrayWithObjects:result1, result2, nil];
	
	SMArtistSimilarityResult *sut = [[SMArtistSimilarityResult alloc] initWithResults:results];
	
	NSSet *expectedItems = [NSSet setWithObjects:item1, nil];
	[self assertExpectedItems:expectedItems cacheable:NO error:YES sut:sut];
}

- (void)testMergeResultsArtistName {
	result1.servicesUsedMask = SMArtistWebServicesLastfm;
	result1.recognizedArtistName = @"Foo";
	result2.recognizedArtistName = @"Bar";
	
	SMArtistSimilarityResult *sut = [[SMArtistSimilarityResult alloc] initWithResults:results];
	
	STAssertEqualObjects(result1.recognizedArtistName, sut.recognizedArtistName, @"Unexpected artist name");
}

@end

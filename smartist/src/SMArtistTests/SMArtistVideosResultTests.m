//
//  SMArtistVideosResultTests.m
//  SMArtist
//
//  Created by Raphael Charwot on 08.02.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "SMArtistVideosResultTests.h"
#import "SMArtistVideosResult.h"
#import "SMArtistResult+Private.h"

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMock/OCMock.h>


@implementation SMArtistVideosResultTests {
	SMArtistVideo *item1;
	SMArtistVideo *item2;
	SMArtistVideosResult *result1;
	SMArtistVideosResult *result2;
	NSArray *results;
}

- (void)setUp {
	item1 = [self itemWithUrl:@"SomeUrl" andTitle:@"SomeTitle"];
	item2 = [self itemWithUrl:@"SomeUrl2" andTitle:@"SomeTitle2"];
	result1 = [self resultWithItem:item1];
	result2 = [self resultWithItem:item2];
	results = [NSArray arrayWithObjects:result1, result2, nil];
}

- (void)tearDown {
}

- (SMArtistVideo *)itemWithUrl:(NSString *)url andTitle:(NSString *)title {
	return [SMArtistVideo artistVideoWithUrl:url andTitle:title];
}

- (SMArtistVideosResult *)resultWithItem:(SMArtistVideo *)item {
	SMArtistVideosResult *result = [[SMArtistVideosResult alloc] init];
	result.videos = [NSArray arrayWithObject:item];
	return result;
}

- (SMArtistVideosResult *)resultWithError {
	SMArtistVideosResult *result = [[SMArtistVideosResult alloc] init];
	result.error = [NSError errorWithDomain:@"SMArtist" code:100 userInfo:nil];
	return result;
}

- (void)assertExpectedItems:(NSSet *)expectedItems cacheable:(BOOL)cacheable error:(BOOL)error sut:(SMArtistVideosResult *)sut {
	STAssertEquals([expectedItems count], [sut.videos count], @"Unexpected number of items");
	STAssertEqualObjects(expectedItems, [NSSet setWithArray:sut.videos], @"Unexpected items");
	STAssertEquals(cacheable, sut.cacheable, @"Unexpected value for cacheable");
	STAssertEquals(error, (BOOL)(sut.error != nil), @"Unexpected value for error");
}

- (void)testMergeResults {
	
	SMArtistVideosResult *sut = [[SMArtistVideosResult alloc] initWithResults:results];
	
	NSSet *expectedItems = [NSSet setWithObjects:item1, item2, nil];
	[self assertExpectedItems:expectedItems cacheable:YES error:NO sut:sut];
}

- (void)testMergeSameResults {
	result2.videos = [NSArray arrayWithObjects:item2, item1, nil];
	
	SMArtistVideosResult *sut = [[SMArtistVideosResult alloc] initWithResults:results];
	
	NSSet *expectedItems = [NSSet setWithObjects:item1, item2, nil];
	[self assertExpectedItems:expectedItems cacheable:YES error:NO sut:sut];
}

- (void)testMergeNonCacheableResults {
	result1.cacheable = NO;
	
	SMArtistVideosResult *sut = [[SMArtistVideosResult alloc] initWithResults:results];
	
	NSSet *expectedItems = [NSSet setWithObjects:item1, item2, nil];
	[self assertExpectedItems:expectedItems cacheable:NO error:NO sut:sut];
}

- (void)testMergeResultsWithError {
	result2 = [self resultWithError];
	results = [NSArray arrayWithObjects:result1, result2, nil];
	
	SMArtistVideosResult *sut = [[SMArtistVideosResult alloc] initWithResults:results];
	
	NSSet *expectedItems = [NSSet setWithObjects:item1, nil];
	[self assertExpectedItems:expectedItems cacheable:NO error:YES sut:sut];
}

- (void)testMergeResultsArtistName {
	result1.servicesUsedMask = SMArtistWebServicesLastfm;
	result1.recognizedArtistName = @"Foo";
	result2.recognizedArtistName = @"Bar";
	
	SMArtistVideosResult *sut = [[SMArtistVideosResult alloc] initWithResults:results];
	
	STAssertEqualObjects(result1.recognizedArtistName, sut.recognizedArtistName, @"Unexpected artist name");
}

@end

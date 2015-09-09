//
//  SMArtistImagesResultTests.m
//  SMArtist
//
//  Created by Raphael Charwot on 08.02.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "SMArtistImagesResultTests.h"
#import "SMArtistImagesResult.h"
#import "SMArtistResult+Private.h"

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMock/OCMock.h>

@implementation SMArtistImagesResultTests {
	SMArtistImage *item1;
	SMArtistImage *item2;
	SMArtistImagesResult *result1;
	SMArtistImagesResult *result2;
	NSArray *results;
}

- (void)setUp {
	item1 = [self itemWithUrl:@"SomeUrl"];
	item2 = [self itemWithUrl:@"SomeUrl2"];
	result1 = [self resultWithItem:item1];
	result2 = [self resultWithItem:item2];
	results = [NSArray arrayWithObjects:result1, result2, nil];
}

- (void)tearDown {
}

- (SMArtistImage *)itemWithUrl:(NSString *)url {
	return [SMArtistImage artistImageWithUrl:url withSize:nil];
}

- (SMArtistImagesResult *)resultWithItem:(SMArtistImage *)item {
	SMArtistImagesResult *result = [[SMArtistImagesResult alloc] init];
	result.images = [NSArray arrayWithObject:item];
	return result;
}

- (SMArtistImagesResult *)resultWithError {
	SMArtistImagesResult *result = [[SMArtistImagesResult alloc] init];
	result.error = [NSError errorWithDomain:@"SMArtist" code:100 userInfo:nil];
	return result;
}

- (void)assertExpectedItems:(NSSet *)expectedItems cacheable:(BOOL)cacheable error:(BOOL)error sut:(SMArtistImagesResult *)sut {
	STAssertEquals([expectedItems count], [sut.images count], @"Unexpected number of items");
	STAssertEqualObjects(expectedItems, [NSSet setWithArray:sut.images], @"Unexpected items");
	STAssertEquals(cacheable, sut.cacheable, @"Unexpected value for cacheable");
	STAssertEquals(error, (BOOL)(sut.error != nil), @"Unexpected value for error");
}

- (void)testMergeResults {
	
	SMArtistImagesResult *sut = [[SMArtistImagesResult alloc] initWithResults:results];
	
	NSSet *expectedItems = [NSSet setWithObjects:item1, item2, nil];
	[self assertExpectedItems:expectedItems cacheable:YES error:NO sut:sut];
}

- (void)testMergeSameResults {
	result2.images = [NSArray arrayWithObjects:item2, item1, nil];
	
	SMArtistImagesResult *sut = [[SMArtistImagesResult alloc] initWithResults:results];
	
	NSSet *expectedItems = [NSSet setWithObjects:item1, item2, nil];
	[self assertExpectedItems:expectedItems cacheable:YES error:NO sut:sut];
}

- (void)testMergeNonCacheableResults {
	result1.cacheable = NO;
	
	SMArtistImagesResult *sut = [[SMArtistImagesResult alloc] initWithResults:results];
	
	NSSet *expectedItems = [NSSet setWithObjects:item1, item2, nil];
	[self assertExpectedItems:expectedItems cacheable:NO error:NO sut:sut];
}

- (void)testMergeResultsWithError {
	result2 = [self resultWithError];
	results = [NSArray arrayWithObjects:result1, result2, nil];
	
	SMArtistImagesResult *sut = [[SMArtistImagesResult alloc] initWithResults:results];
	
	NSSet *expectedItems = [NSSet setWithObjects:item1, nil];
	[self assertExpectedItems:expectedItems cacheable:NO error:YES sut:sut];
}

- (void)testMergeResultsArtistName {
	result1.servicesUsedMask = SMArtistWebServicesLastfm;
	result1.recognizedArtistName = @"Foo";
	result2.recognizedArtistName = @"Bar";
	
	SMArtistImagesResult *sut = [[SMArtistImagesResult alloc] initWithResults:results];
	
	STAssertEqualObjects(result1.recognizedArtistName, sut.recognizedArtistName, @"Unexpected artist name");
}

@end

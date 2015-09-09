//
//  SMArtistBiosResultTests.m
//  SMArtist
//
//  Created by Raphael Charwot on 08.02.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "SMArtistBiosResultTests.h"
#import "SMArtistBiosResult.h"
#import "SMArtistResult+Private.h"

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMock/OCMock.h>

@implementation SMArtistBiosResultTests {
	SMArtistBio *item1;
	SMArtistBio *item2;
	SMArtistBiosResult *result1;
	SMArtistBiosResult *result2;
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

- (SMArtistBio *)itemWithUrl:(NSString *)url {
	return [SMArtistBio artistBioWithUrl:url withSourceName:nil withPreviewText:nil withFullText:nil];
}

- (SMArtistBiosResult *)resultWithItem:(SMArtistBio *)item {
	SMArtistBiosResult *result = [[SMArtistBiosResult alloc] init];
	result.bios = [NSArray arrayWithObject:item];
	return result;
}

- (SMArtistBiosResult *)resultWithError {
	SMArtistBiosResult *result = [[SMArtistBiosResult alloc] init];
	result.error = [NSError errorWithDomain:@"SMArtist" code:100 userInfo:nil];
	return result;
}

- (void)assertExpectedItems:(NSSet *)expectedItems cacheable:(BOOL)cacheable error:(BOOL)error sut:(SMArtistBiosResult *)sut {
	STAssertEquals([expectedItems count], [sut.bios count], @"Unexpected number of items");
	STAssertEqualObjects(expectedItems, [NSSet setWithArray:sut.bios], @"Unexpected items");
	STAssertEquals(cacheable, sut.cacheable, @"Unexpected value for cacheable");
	STAssertEquals(error, (BOOL)(sut.error != nil), @"Unexpected value for error");
}

- (void)testMergeResults {

	SMArtistBiosResult *sut = [[SMArtistBiosResult alloc] initWithResults:results];
	
	NSSet *expectedItems = [NSSet setWithObjects:item1, item2, nil];
	[self assertExpectedItems:expectedItems cacheable:YES error:NO sut:sut];
}

- (void)testMergeSameResults {
	result2.bios = [NSArray arrayWithObjects:item2, item1, nil];
	
	SMArtistBiosResult *sut = [[SMArtistBiosResult alloc] initWithResults:results];
	
	NSSet *expectedItems = [NSSet setWithObjects:item1, item2, nil];
	[self assertExpectedItems:expectedItems cacheable:YES error:NO sut:sut];
}

- (void)testMergeNonCacheableResults {
	result1.cacheable = NO;
	
	SMArtistBiosResult *sut = [[SMArtistBiosResult alloc] initWithResults:results];
	
	NSSet *expectedItems = [NSSet setWithObjects:item1, item2, nil];
	[self assertExpectedItems:expectedItems cacheable:NO error:NO sut:sut];
}

- (void)testMergeResultsWithError {
	result2 = [self resultWithError];
	results = [NSArray arrayWithObjects:result1, result2, nil];
	
	SMArtistBiosResult *sut = [[SMArtistBiosResult alloc] initWithResults:results];
	
	NSSet *expectedItems = [NSSet setWithObjects:item1, nil];
	[self assertExpectedItems:expectedItems cacheable:NO error:YES sut:sut];
}

- (void)testMergeResultsArtistName {
	result1.servicesUsedMask = SMArtistWebServicesLastfm;
	result1.recognizedArtistName = @"Foo";
	result2.recognizedArtistName = @"Bar";
	
	SMArtistBiosResult *sut = [[SMArtistBiosResult alloc] initWithResults:results];
	
	STAssertEqualObjects(result1.recognizedArtistName, sut.recognizedArtistName, @"Unexpected artist name");
}


@end

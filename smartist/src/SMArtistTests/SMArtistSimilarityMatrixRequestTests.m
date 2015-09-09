//
//  SMArtistSimilarityMatrixRequestTests.m
//  SMArtist
//
//  Created by Raphael Charwot on 15.02.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "SMArtistSimilarityMatrixRequestTests.h"
#import "SMArtistSimilarityMatrixRequest.h"
#import "TestHelper.h"

@implementation SMArtistSimilarityMatrixRequestTests

- (SMArtistSimilarityMatrixRequest *)requestWithArtistNames:(NSArray *)artistNames servicesMask:(SMArtistWebServices)servicesMask {
	return [[SMArtistSimilarityMatrixRequest alloc] initWithArtistNames:artistNames clientId:nil services:servicesMask configFactory:nil];
}

- (void)testCachingIdSame {
	NSArray *artistNames = [NSArray arrayWithObjects:@"Test-Artist", @"OtherArtist", nil];
	SMArtistWebServices servicesMask = SMArtistWebServicesEchonest;

	SMArtistSimilarityMatrixRequest *requestA = [self requestWithArtistNames:artistNames servicesMask:servicesMask];
	SMArtistSimilarityMatrixRequest *requestB = [self requestWithArtistNames:artistNames servicesMask:servicesMask];
	
	STAssertEqualObjects([requestA cachingId], [requestB cachingId], @"Should be equal");
}

- (void)testCachingIdSameReordered {
	NSArray *artistNamesA = [NSArray arrayWithObjects:@"Test-Artist", @"OtherArtist", nil];
	NSArray *artistNamesB = [NSArray arrayWithObjects:@"OtherArtist", @"Test-Artist", nil];
	SMArtistWebServices servicesMask = SMArtistWebServicesEchonest;

	SMArtistSimilarityMatrixRequest *requestA = [self requestWithArtistNames:artistNamesA servicesMask:servicesMask];
	SMArtistSimilarityMatrixRequest *requestB = [self requestWithArtistNames:artistNamesB servicesMask:servicesMask];

	STAssertEqualObjects([requestA cachingId], [requestB cachingId], @"Should be equal for reordered names");
}

- (void)testCachingIdDifferentArtists {
	NSArray *artistNamesA = [NSArray arrayWithObjects:@"Test-Artist", @"OtherArtist", nil];
	NSArray *artistNamesB = [NSArray arrayWithObjects:@"Test-Artist", @"OtherArtist 2", nil];
	SMArtistWebServices servicesMask = SMArtistWebServicesEchonest;

	SMArtistSimilarityMatrixRequest *requestA = [self requestWithArtistNames:artistNamesA servicesMask:servicesMask];
	SMArtistSimilarityMatrixRequest *requestB = [self requestWithArtistNames:artistNamesB servicesMask:servicesMask];

	STAssertDifferentObjects([requestA cachingId], [requestB cachingId], @"Should be different for different artists");
}

@end

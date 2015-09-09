//
//  SMSingleArtistRequestTests.m
//  SMArtist
//
//  Created by Raphael Charwot on 15.02.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "SMSingleArtistRequestTests.h"
#import "SMSingleArtistRequest.h"
#import "SMArtistSimilarityMatrixRequest.h"
#import "TestHelper.h"

@implementation SMSingleArtistRequestTests

- (SMSingleArtistRequest *)requestWithType:(enum SMSingleArtistRequestType)type artistName:(NSString *)artistName servicesMask:(SMArtistWebServices)servicesMask {
	return [[SMSingleArtistRequest alloc] initWithArtistName:artistName requestType:type clientId:nil servicesMask:servicesMask configFactory:nil];
}

- (void)testCachingIdSame {
	enum SMSingleArtistRequestType type = SMSingleArtistRequestTypeArtistSimilarity;
	NSString *artistName = @"Test-Artist";
	SMArtistWebServices servicesMask = SMArtistWebServicesEchonest;
	SMSingleArtistRequest *requestA = [self requestWithType:type artistName:artistName servicesMask:servicesMask];
	SMSingleArtistRequest *requestB = [self requestWithType:type artistName:artistName servicesMask:servicesMask];
	
	STAssertEqualObjects([requestA cachingId], [requestB cachingId], @"Should be equal");
}

- (void)testCachingIdDifferentArtists {
	enum SMSingleArtistRequestType type = SMSingleArtistRequestTypeArtistSimilarity;
	SMArtistWebServices servicesMask = SMArtistWebServicesEchonest;
	SMSingleArtistRequest *requestA = [self requestWithType:type artistName:@"Test-Artist" servicesMask:servicesMask];
	SMSingleArtistRequest *requestB = [self requestWithType:type artistName:@"Other-Artist" servicesMask:servicesMask];
	
	STAssertDifferentObjects([requestA cachingId], [requestB cachingId], @"Should be different for different artist");
}

- (void)testCachingIdDifferentServicesMasks {
	enum SMSingleArtistRequestType type = SMSingleArtistRequestTypeArtistSimilarity;
	NSString *artistName = @"Test-Artist";
	SMSingleArtistRequest *requestA = [self requestWithType:type artistName:artistName servicesMask:SMArtistWebServicesEchonest];
	SMSingleArtistRequest *requestB = [self requestWithType:type artistName:artistName servicesMask:SMArtistWebServicesYoutube];
	
	STAssertDifferentObjects([requestA cachingId], [requestB cachingId], @"Should be different for different servicesMasks");
}

- (void)testCachingIdDifferentTypes {
	NSArray *requestTypes = [NSArray arrayWithObjects:
							 [NSNumber numberWithInt:SMSingleArtistRequestTypeArtistSimilarity],
							 [NSNumber numberWithInt:SMSingleArtistRequestTypeArtistBios],
							 [NSNumber numberWithInt:SMSingleArtistRequestTypeArtistImages],
							 [NSNumber numberWithInt:SMSingleArtistRequestTypeArtistVideos],
							 nil];
	
	NSString *artistName = @"Test-Artist";
	SMArtistWebServices servicesMask = SMArtistWebServicesEchonest;
	
	SMArtistSimilarityMatrixRequest *matrixRequest = [[SMArtistSimilarityMatrixRequest alloc] initWithArtistNames:[NSArray arrayWithObject:artistName] clientId:nil services:servicesMask configFactory:nil];
	
	for(NSNumber *requestTypeA in requestTypes) {
		SMSingleArtistRequest *requestA = [self requestWithType:[requestTypeA intValue] artistName:artistName servicesMask:servicesMask];
		
		STAssertDifferentObjects([requestA cachingId], [matrixRequest cachingId], @"Should be different for different requestTypes");
		for(NSNumber *requestTypeB in requestTypes) {
			if(requestTypeA == requestTypeB) {
				continue;
			}
			SMSingleArtistRequest *requestB = [self requestWithType:[requestTypeB intValue] artistName:artistName servicesMask:servicesMask];
			STAssertDifferentObjects([requestA cachingId], [requestB cachingId], @"Should be different for different requestTypes");
		}
	}
}

@end

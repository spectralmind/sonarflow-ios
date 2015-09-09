//
//  SMArtistRequestFactory.m
//  SMArtist
//
//  Created by Fabian on 25.11.11.
//  Copyright (c) 2011 Spectralmind. All rights reserved.
//

#import "SMArtistRequestFactory.h"
#import "SMRootFactory.h"

#import "SMSingleArtistRequest.h"
#import "SMArtistSimilarityMatrixRequest.h"

@interface SMArtistRequestFactory ()

@end


@implementation SMArtistRequestFactory {
    SMRootFactory *__weak rootFactory;
}

@synthesize rootFactory;

- (SMArtistRequest *)artistBiosRequestWithClientId:(id)clientId withArtistName:(NSString *)artistName priority:(BOOL)priority {
	SMArtistWebServices servicesMask = self.rootFactory.configuration.servicesMaskBiosRequests;
	SMSingleArtistRequest *request = [[SMSingleArtistRequest alloc] initWithArtistName:artistName requestType:SMSingleArtistRequestTypeArtistBios clientId:clientId servicesMask:servicesMask configFactory:self.rootFactory];
	request.priority = priority;
	return request;
}

- (SMArtistRequest *)artistSimilarityRequestWithClientId:(id)clientId withArtistName:(NSString *)artistName priority:(BOOL)priority {
	SMArtistWebServices servicesMask = self.rootFactory.configuration.servicesMaskSimilarityRequests;
	SMSingleArtistRequest *request = [[SMSingleArtistRequest alloc] initWithArtistName:artistName requestType:SMSingleArtistRequestTypeArtistSimilarity clientId:clientId servicesMask:servicesMask configFactory:self.rootFactory];
	request.priority = priority;
	return request;
}

- (SMArtistRequest *)artistSimilarityMatrixRequestWithClientId:(id)clientId withArtistNames:(NSArray *)artistNames priority:(BOOL)priority {
	SMArtistSimilarityMatrixRequest *request = [[SMArtistSimilarityMatrixRequest alloc] initWithArtistNames:artistNames clientId:clientId services:self.rootFactory.configuration.servicesMaskSimilarityRequests configFactory:self.rootFactory];
	request.priority = priority;
	return request;
}

- (SMArtistRequest *)artistImagesRequestWithClientId:(id)clientId withArtistName:(NSString *)artistName priority:(BOOL)priority {
	SMArtistWebServices servicesMask = self.rootFactory.configuration.servicesMaskImagesRequests;
	SMSingleArtistRequest *request = [[SMSingleArtistRequest alloc] initWithArtistName:artistName requestType:SMSingleArtistRequestTypeArtistImages clientId:clientId servicesMask:servicesMask configFactory:self.rootFactory];
	request.priority = priority;
	return request;
}

- (SMArtistRequest *)artistVideosRequestWithClientId:(id)clientId withArtistName:(NSString *)artistName priority:(BOOL)priority {
	SMArtistWebServices servicesMask = self.rootFactory.configuration.servicesMaskVideosRequests;
	SMSingleArtistRequest *request = [[SMSingleArtistRequest alloc] initWithArtistName:artistName requestType:SMSingleArtistRequestTypeArtistVideos clientId:clientId servicesMask:servicesMask configFactory:self.rootFactory];
	request.priority = priority;
	return request;
}

- (SMArtistRequest *)artistGenresRequestWithClientId:(id)clientId withArtistName:(NSString *)artistName priority:(BOOL)priority {
	SMArtistWebServices servicesMask = self.rootFactory.configuration.servicesMaskGenresRequests;
	SMSingleArtistRequest *request = [[SMSingleArtistRequest alloc] initWithArtistName:artistName requestType:SMSingleArtistRequestTypeArtistGenres clientId:clientId servicesMask:servicesMask configFactory:self.rootFactory];
	request.priority = priority;
	return request;
}

@end

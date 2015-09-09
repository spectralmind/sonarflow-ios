//
//  SMArtistWebInfo.m
//  SMArtist
//
//  Created by Fabian on 17.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//

#import "SMArtistWebInfo+Private.h"

#import "SMRootFactory.h"

#import "SMArtistWebInfoHttpGetJsonLastfm.h"
#import "SMArtistWebInfoHttpGetJsonEchonest.h"
#import "SMArtistWebInfoHttpGetJsonYoutube.h"

#import "SMArtistBiosResult.h"
#import "SMArtistSimilarityResult.h"
#import "SMArtistSimilarityMatrixResult.h"
#import "SMArtistImagesResult.h"

#import "SMRateLimitedQueue.h"

@implementation SMArtistWebInfo {
	@private
	SMSingleArtistRequest *request;
	SMRateLimitedQueue *requestQueue;
}

+ (SMArtistWebInfo *)webinfoWithConfiguration:(SMRootFactory *)theRootFactory withDelegate:(id<SMRequestableDelegate>)theDelegate ForWebservice:(SMArtistWebServices)webservice forRequestType:(SMSingleArtistRequestType)requesttype
{
	switch (webservice) {
		case SMArtistWebServicesLastfm:
			return [SMArtistWebInfoHttpGetJsonLastfm webinfoLastfmWithConfiguration:theRootFactory withDelegate:theDelegate forRequestType:requesttype];

		case SMArtistWebServicesEchonest:
			return [SMArtistWebInfoHttpGetJsonEchonest webinfoEchonestWithConfiguration:theRootFactory withDelegate:theDelegate forRequestType:requesttype];
			
		case SMArtistWebServicesYoutube:
			return [SMArtistWebInfoHttpGetJsonYoutube webinfoYoutubeWithConfiguration:theRootFactory withDelegate:theDelegate forRequestType:requesttype];
			
		default:
			NSAssert(NO, @"wrong webservice specified, only one is allowed: %i", webservice);
			return nil;
	}
}


@synthesize request;

- (void)setRequest:(SMSingleArtistRequest *)newRequest {
	if(request == newRequest) {
		return;
	}
	
	if(newRequest != nil) {
		NSAssert(newRequest.type == [self servingRequestType], @"Request Type is of wrong type.");
	}
	
	request = newRequest;
}

- (id)init
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)initWithConfiguration:(SMRootFactory *)theConfigfactory withDelegate:(id<SMRequestableDelegate>)theDelegate withQueue:(SMRateLimitedQueue *)theQueue
{
    self = [super initWithConfiguration:theConfigfactory withDelegate:theDelegate];
    if (self) {
		requestQueue = theQueue;
    }
    
    return self;
}


#pragma mark - Overridden Public Methods

- (void)startRequest
{
	NSAssert(self.request != nil, @"Request was not set before startRequest");
	NSAssert(requestQueue != nil, @"attempt to start a request without a queue");
	
	[requestQueue enqueueWithPriority:self.request.priority block:^{
		[self doRequest];
	}];
}

#pragma mark - Abstract Protected Methods

- (void)doRequest
{
	[self doesNotRecognizeSelector:_cmd];
}

- (SMArtistResult *)emptyResult {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (SMArtistWebServices)service {
	[self doesNotRecognizeSelector:_cmd];
	return 0;
}

- (SMSingleArtistRequestType)servingRequestType {
	[self doesNotRecognizeSelector:_cmd];
	return 0;
}

- (void)setResultDetails:(SMArtistResult *)result {
	result.request = self.request;
	result.servicesUsedMask = [self service];
}


#pragma mark - Private Helper Methods

- (void)setAvailable {
	self.request = nil;
}

- (void)sendOutErrorResultWithError:(NSError *)error
{
	SMArtistResult *result = [self emptyResult];
	result.error = error;
	[self setResultDetails:result];
	[self.delegate doneSMRequestWithRequestable:self withResult:result];
	
	[self setAvailable];
}

// TODO make error code parameter?
- (void)sendOutErrorResultWithErrorString:(NSString *)errorString
{
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionaryWithObjectsAndKeys:errorString,NSLocalizedDescriptionKey, nil];
    [self sendOutErrorResultWithError:[NSError errorWithDomain:@"SMArtist" code:100 userInfo:errorDetail]];
}

- (void)sendOutResult:(SMArtistResult *)result
{
	[self setResultDetails:result];
	result.cacheable = YES;
    [self.delegate doneSMRequestWithRequestable:self withResult:result];
	[self setAvailable];
}


@end

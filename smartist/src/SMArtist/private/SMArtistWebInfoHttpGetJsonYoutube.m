//
//  SMArtistWebInfoHttpGetJsonYoutube.m
//  SMArtist
//
//  Created by Fabian on 01.02.12.
//  Copyright (c) 2012 Spectralmind. All rights reserved.
//

#import "SMArtistWebInfoHttpGetJsonYoutube.h"
#import "SMArtistWebInfoHttpGetJson+Private.h"
#import "SMArtistWebInfo+Private.h"

#import "SMRootFactory.h"

#import "NSDictionary+SMArtist_JSON.h"

#import "SMArtistVideosResult.h"
#import "SMArtistVideo.h"

#import "NSString+SMArtist_urlescape.h"
#import "SMRateLimitedQueue.h"

static NSUInteger const kResultLimit = 50;


@interface SMArtistWebInfoHttpGetJsonYoutube ()

- (id)extractFromYoutubeDict:(NSDictionary *)responseDict;

@end


@implementation SMArtistWebInfoHttpGetJsonYoutube
{
@protected
    uint _limit;
}


- (id)init
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)initWithConfiguration:(SMRootFactory *)rootFactory withDelegate:(id<SMRequestableDelegate>)delegate withQueue:(SMRateLimitedQueue *)theQueue
{
    self = [super initWithConfiguration:rootFactory withDelegate:delegate withQueue:theQueue];
    if (self) {
        // Initialization code here.
        _limit = kResultLimit;
    }
    
    return self;
}


+ (SMArtistWebInfo *)webinfoYoutubeWithConfiguration:(SMRootFactory *)theRootFactory withDelegate:(id<SMRequestableDelegate>)theDelegate forRequestType:(SMSingleArtistRequestType)requesttype
{
	SMRateLimitedQueue *queue = [theRootFactory getQueueForYoutube];
	NSAssert(queue != nil, @"undefined queue!");

	switch (requesttype) {
        case SMSingleArtistRequestTypeArtistVideos:
			
			return [[SMArtistWebInfoHttpGetJsonYoutube alloc] initWithConfiguration:theRootFactory withDelegate:theDelegate withQueue:queue];
			
        default:
			// ignore unsupported request types
			return nil;
    }
}



#pragma mark - Private Methods

#pragma mark Query Url Construction

// Get Query String for Youtube API
- (NSString *)getYoutubeQueryStringForEndpoint:(NSString *)endpoint withParameters:(NSDictionary *)parameters
{
    NSMutableString *getString = [NSMutableString stringWithFormat:@"%@%@?&alt=jsonc&v=2",
								  self.rootFactory.configuration.youtubeUrl,
								  endpoint];
    
    for(NSString *key in parameters) {
		NSString *parameter = [parameters objectForKey:key];
		parameter = [parameter sma_urlescape];
		[getString appendFormat:@"&%@=%@",key,parameter];
    }
    
    return getString;
}


#pragma mark Make Actual Web Request

- (void)doRequestOfType:(SMSingleArtistRequestType)type forEndpoint:(NSString *)endpoint withParameters:(NSDictionary *)parameters
{
	NSString *requeststring = [self getYoutubeQueryStringForEndpoint:endpoint withParameters:parameters];
	[self doAndProcessHttpUrlRequestForUrl:requeststring];
}


#pragma mark Process and Return Results to Delegate

- (void)processAndSendOutResultWithInfo:(id)theInfo
{
	SMArtistVideosResult *result = (SMArtistVideosResult *)[self emptyResult];
	id subinfo = [self extractFromYoutubeDict:theInfo];
	result.recognizedArtistName = self.request.artistName;
	result.videos = subinfo;
	[self sendOutResult:result];
}


#pragma mark JSON Parsing

- (id)extractFromYoutubeDict:(NSDictionary *)responseDict
{
	//{"data": {"items": [{"id": "VIDEO_ID"}]}}
	//{"data": {"items": [{"player": {"default": "https://www.youtube.com/watch?v=LanCLS_hIo4&feature=youtube_gdata_player"}}]}}
	//{"data": {"items": [{"status": {"value": "restricted"}]}}
	//{"data": {"items": [{"accessControl": {"embed": "allowed","syndicate": "denied"}]}}
	
	NSMutableArray *urlStrings = [[NSMutableArray alloc] init];

	NSArray *items = [[responseDict sma_dictionaryForKey:@"data"] sma_makeArrayOfObjectForKey:@"items"];
	
	for (NSDictionary *i in items) {
		if (![i isKindOfClass:[NSDictionary class]]) {
			NSLog(@"ignoring result: %@", i);
			continue;
		}
		
		NSString *urlPrefix = @"http://www.youtube.com/embed/";
		NSString *videoID = [i sma_stringForKey:@"id"];
		NSString *url = [urlPrefix stringByAppendingString:videoID];
		NSString *restriction = [[i sma_dictionaryForKey:@"status"] sma_stringForKey:@"value"];
		NSString *title = [i sma_stringForKey:@"title"];
		
		if (!(restriction == nil || ![restriction compare:@"restricted"] == NSOrderedSame)) {
			// ignore video that cannot be played back on device
			continue;
		}
		
		SMArtistVideo *video = [SMArtistVideo artistVideoWithUrl:url andTitle:title];
		
		if ([video isValid]) {
			[urlStrings addObject:video];
		}
	}
	
	return urlStrings;
}

- (BOOL)isErrorInResponse:(NSDictionary *)response
{
	return ([response sma_dictionaryForKey:@"error"] != nil);
}

- (NSString *)errorStringFromResponse:(NSDictionary *)response
{
	return [[response sma_dictionaryForKey:@"error"] sma_stringForKey:@"message"] ;
}


#pragma mark - Protected Overridden Methods

- (void)doRequest
{
	[self doRequestOfType:SMSingleArtistRequestTypeArtistVideos
			  forEndpoint:@"videos"
		   withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
						   self.request.artistName,@"q",
						   [NSString stringWithFormat:@"%d",_limit],@"max-results",
						   @"Music",@"category",
						   @"5",@"format",
						   nil]
	 ];
}

- (NSTimeInterval)urlRequestTimeoutInterval
{
	return self.rootFactory.configuration.youtubeTimeout;
}

- (void)processJsonResponse:(id)response
{
	if (![response isKindOfClass:[NSDictionary class]]) {
		[self sendOutErrorResultWithErrorString:[NSString stringWithFormat:@"error: could not parse json: %@", [response description]]];
		return;
	}
	
	if ([self isErrorInResponse:response]) {
		[self sendOutErrorResultWithErrorString:[NSString stringWithFormat:@"Youtube returned error: %@", [self errorStringFromResponse:response]]];
	} else {
		[self processAndSendOutResultWithInfo:response];
	}
}

- (SMArtistWebServices)service
{
	return SMArtistWebServicesYoutube;
}


- (SMArtistResult *)emptyResult
{
	return [SMArtistVideosResult result];
}

- (SMSingleArtistRequestType)servingRequestType
{
	return SMSingleArtistRequestTypeArtistVideos;
}


@end

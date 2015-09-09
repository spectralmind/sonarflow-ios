//
//  SMArtistWebInfoEchonest.m
//  SMArtist
//
//  Created by Fabian on 19.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//

#import "SMArtistWebInfoHttpGetJsonEchonest.h"
#import "SMArtistWebInfoHttpGetJson+Private.h"
#import "SMArtistWebInfo+Private.h"

#import "SMRootFactory.h"

#import "NSDictionary+SMArtist_JSON.h"

#import "SMArtistBiosResult.h"
#import "SMArtistBio.h"
#import "SMArtistSimilarityResult.h"
#import "SMSimilarArtist.h"
#import "SMArtistImagesResult.h"
#import "SMArtistImage.h"

#import "NSString+SMArtist_urlescape.h"

static NSUInteger const kResponseCodeInvalidParameter = 5;
static NSUInteger const kResultLimit = 30;


@interface SMArtistWebInfoHttpGetJsonEchonestBios : SMArtistWebInfoHttpGetJsonEchonest
@end

@interface SMArtistWebInfoHttpGetJsonEchonestImages : SMArtistWebInfoHttpGetJsonEchonest
@end

@interface SMArtistWebInfoHttpGetJsonEchonestSimilarity : SMArtistWebInfoHttpGetJsonEchonest
@end


@implementation SMArtistWebInfoHttpGetJsonEchonest
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

+ (SMArtistWebInfo *)webinfoEchonestWithConfiguration:(SMRootFactory *)theRootFactory withDelegate:(id<SMRequestableDelegate>)theDelegate forRequestType:(SMSingleArtistRequestType)requesttype
{
	SMRateLimitedQueue *queue = [theRootFactory getQueueForEchonest];
	NSAssert(queue != nil, @"undefined queue!");
	
	switch (requesttype) {
        case SMSingleArtistRequestTypeArtistBios:
			return [[SMArtistWebInfoHttpGetJsonEchonestBios alloc] initWithConfiguration:theRootFactory withDelegate:theDelegate withQueue:queue];

        case SMSingleArtistRequestTypeArtistSimilarity:
			return [[SMArtistWebInfoHttpGetJsonEchonestSimilarity alloc] initWithConfiguration:theRootFactory withDelegate:theDelegate withQueue:queue];

		case SMSingleArtistRequestTypeArtistImages:
			return [[SMArtistWebInfoHttpGetJsonEchonestImages alloc] initWithConfiguration:theRootFactory withDelegate:theDelegate withQueue:queue];

        default:
			// ignore unsupported request types
			return nil;
    }
}

#pragma mark - Abstract Protected Methods

- (id)extractFromEchonestDict:(NSDictionary *)responseDict
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (void)fillResult:(SMArtistResult *)result withInfo:(id)info
{
	[self doesNotRecognizeSelector:_cmd];
}


#pragma mark - Private Methods

#pragma mark Query Url Construction

// Get Query String for Echonest API
- (NSString *)getEchonestQueryStringForEndpoint:(NSString *)endpoint withParameters:(NSDictionary *)parameters
{
    NSMutableString *getString = [NSMutableString stringWithFormat:@"%@%@?api_key=%@&format=json",
								  self.rootFactory.configuration.echonestUrl,
								  endpoint,
								  self.rootFactory.configuration.echonestKey];
    
    for(NSString *key in parameters) {
		NSString *parameter = [parameters objectForKey:key];
		parameter = [parameter sma_urlescape];
		[getString appendFormat:@"&%@=%@",key,parameter];
    }
    
    return getString;
}


#pragma mark Make Actual Web Request

- (void)doRequestForEndpoint:(NSString *)endpoint withParameters:(NSDictionary *)parameters
{
	NSString *requeststring = [self getEchonestQueryStringForEndpoint:endpoint withParameters:parameters];
	[self doAndProcessHttpUrlRequestForUrl:requeststring];
}


#pragma mark Process and Return Results to Delegate

- (void)processAndSendOutResultWithInfo:(id)theInfo
{
	SMArtistResult *result = [self emptyResult];
	id subinfo = [self extractFromEchonestDict:theInfo];
	result.recognizedArtistName = self.request.artistName;
	[self fillResult:result withInfo:subinfo];
	[self sendOutResult:result];
}


#pragma mark JSON Parsing

- (BOOL)isUnknownArtistErrorInResponse:(NSDictionary *)response
{
	if ([[[[response sma_dictionaryForKey:@"response"] sma_dictionaryForKey:@"status"] sma_stringForKey:@"code"] intValue] == kResponseCodeInvalidParameter &&
		[[response sma_stringForKey:@"message"] rangeOfString:@"Identifier"].location != NSNotFound &&
		[[response sma_stringForKey:@"message"] rangeOfString:@"exist"].location != NSNotFound) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)isErrorInResponse:(NSDictionary *)response
{
	return ([[[[response sma_dictionaryForKey:@"response"] sma_dictionaryForKey:@"status"] sma_stringForKey:@"code"] intValue] != 0);
}

- (NSString *)errorStringFromResponse:(NSDictionary *)response
{
	return [[[response sma_dictionaryForKey:@"response"] sma_dictionaryForKey:@"status"] sma_stringForKey:@"message"];
}


#pragma mark - Protected Overridden Methods

- (NSTimeInterval)urlRequestTimeoutInterval
{
	return self.rootFactory.configuration.echonestTimeout;
}

- (void)processJsonResponse:(id)response
{
	if (![response isKindOfClass:[NSDictionary class]]) {
		[self sendOutErrorResultWithErrorString:[NSString stringWithFormat:@"error: could not parse json: %@", [response description]]];
		return;
	}
	
	if ([self isErrorInResponse:response]) {
		if ([self isUnknownArtistErrorInResponse:response]) {
			[self processAndSendOutResultWithInfo:nil];
		} else {
			[self sendOutErrorResultWithErrorString:[NSString stringWithFormat:@"Echonest returned error: %@", [self errorStringFromResponse:response]]];
		}
	} else {
		[self processAndSendOutResultWithInfo:response];
	}
}

- (SMArtistWebServices)service
{
	return SMArtistWebServicesEchonest;
}

@end


#pragma mark - Subclasses

@implementation SMArtistWebInfoHttpGetJsonEchonestBios

- (SMArtistResult *)emptyResult
{
	return [SMArtistBiosResult result];
}

- (SMSingleArtistRequestType)servingRequestType
{
	return SMSingleArtistRequestTypeArtistBios;
}

- (void)fillResult:(SMArtistBiosResult *)result withInfo:(NSArray *)info
{
	result.bios = info;
}

- (void)doRequest
{
	[self doRequestForEndpoint:@"artist/biographies"
		   withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
						   self.request.artistName,@"name",
						   [NSString stringWithFormat:@"%d",_limit],@"results",
						   nil]
	 ];
}

- (NSArray *)extractFromEchonestDict:(NSDictionary *)responseDict
{
	// {response {biographies [{url}]}}
    
    NSMutableArray *returnArray = [NSMutableArray array];
    
    NSArray *bioArray = [[responseDict sma_dictionaryForKey:@"response"] sma_makeArrayOfObjectForKey:@"biographies"];
    
    for(NSMutableDictionary *bioInfo in bioArray) {
		if (![bioInfo isKindOfClass:[NSDictionary class]]) {
			NSLog(@"ignoring result: %@", bioInfo);
			continue;
		}
		
        NSString *bioUrl = [bioInfo sma_stringForKey:@"url"];
        
        NSString *site = [bioInfo sma_stringForKey:@"site"]; // TODO translate strings / caps
        
        NSString *previewText = nil;
        NSString *fullText = nil;
        NSString *text = [bioInfo sma_stringForKey:@"text"];
        
		NSNumber *truncated = [bioInfo sma_numberForKey:@"truncated"];

        if (truncated != nil && [truncated boolValue]) {
            //NSLog(@"SHORTBIO: %@",text);
            previewText = text;
        } else {
            //NSLog(@"LONGBIO: %@",text);
            fullText = text;
            previewText = [[text substringToIndex:200] stringByAppendingString:@" ..."];
        }
		
        SMArtistBio *bio = [SMArtistBio artistBioWithUrl:bioUrl withSourceName:site withPreviewText:previewText withFullText:fullText];
        
        if ([bio isValid]) {
            [returnArray addObject:bio];
        }
    }
    
    return returnArray;
}

@end


@implementation SMArtistWebInfoHttpGetJsonEchonestImages

- (SMArtistResult *)emptyResult
{
	return [SMArtistImagesResult result];
}

- (SMSingleArtistRequestType)servingRequestType
{
	return SMSingleArtistRequestTypeArtistImages;
}

- (void)fillResult:(SMArtistImagesResult *)result withInfo:(NSArray *)info
{
	result.images = info;
}

- (void)doRequest
{
	[self doRequestForEndpoint:@"artist/images"
		   withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
						   self.request.artistName,@"name",
						   [NSString stringWithFormat:@"%d",_limit],@"results",
						   nil]
	 ];
}

- (NSArray *)extractFromEchonestDict:(NSDictionary *)responseDict
{
	// {response {images [{url}]}}
    
    NSMutableArray *returnArray = [NSMutableArray array];
    
    NSArray *imagesArray = [[responseDict sma_dictionaryForKey:@"response"] sma_makeArrayOfObjectForKey:@"images"];
    
    for(NSMutableDictionary *imageInfo in imagesArray) {
		if (![imageInfo isKindOfClass:[NSDictionary class]]) {
			NSLog(@"ignoring result: %@", imageInfo);
			continue;
		}

        NSString *imageUrl = [imageInfo sma_stringForKey:@"url"];
		
        SMArtistImage *image = [SMArtistImage artistImageWithUrl:imageUrl withSize:nil]; // size unknown
        
        if ([image isValid]) {
            [returnArray addObject:image];
        }
    }
    
    return returnArray;
}

@end


@implementation SMArtistWebInfoHttpGetJsonEchonestSimilarity

- (SMArtistResult *)emptyResult
{
	return [SMArtistSimilarityResult result];
}

- (SMSingleArtistRequestType)servingRequestType
{
	return SMSingleArtistRequestTypeArtistSimilarity;
}

- (void)fillResult:(SMArtistSimilarityResult *)result withInfo:(NSArray *)info
{
	result.similarArtists = info;
}

- (void)doRequest
{
	[self doRequestForEndpoint:@"artist/similar"
		   withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
						   self.request.artistName,@"name",
						   [NSString stringWithFormat:@"%d",_limit],@"results",
						   nil]
	 ];
}

- (NSArray *)extractFromEchonestDict:(NSDictionary *)responseDict
{
	// {response {artists [{name}]}}
	
	NSMutableArray *returnArray = [NSMutableArray array];
	
	NSArray *artistsArray = [[responseDict sma_dictionaryForKey:@"response"] sma_makeArrayOfObjectForKey:@"artists"];
	
	for(NSMutableDictionary *artistInfo in artistsArray) {
		if (![artistInfo isKindOfClass:[NSDictionary class]]) {
			NSLog(@"ignoring result: %@", artistInfo);
			continue;
		}
		
		NSString *artistName = [artistInfo sma_stringForKey:@"name"];
		
		// TODO refine FAKE value generation
		CGFloat matchValue = 1.f;
		matchValue = fmaxf(1.f, fminf(0.f, matchValue));

		SMSimilarArtist *similarArtist = [SMSimilarArtist similarArtistWithName:artistName withMatchValue:matchValue];
		
		if ([similarArtist isValid]) {
			[returnArray addObject:similarArtist];
		}
	}
	
	return returnArray;
}

@end



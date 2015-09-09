//
//  SMArtistWebInfoLastfm.m
//  SMArtist
//
//  Created by Fabian on 19.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//

#import "SMArtistWebInfoHttpGetJsonLastfm.h"
#import "SMArtistWebInfoHttpGetJson+Private.h"
#import "SMArtistWebInfo+Private.h"

#import "NSArray+SingleElement.h"
#import "NSDictionary+SMArtist_JSON.h"
#import "NSString+SMArtist_urlescape.h"
#import "SMArtistBio.h"
#import "SMArtistBiosResult.h"
#import "SMArtistGenresResult.h"
#import "SMArtistImage.h"
#import "SMArtistImagesResult.h"
#import "SMArtistSimilarityResult.h"
#import "SMRootFactory.h"
#import "SMSimilarArtist.h"

static NSUInteger const kResponseCodeInvalidParameter = 6;
static NSUInteger const kResultLimit = 30;


@interface SMArtistWebInfoHttpGetJsonLastfmBios : SMArtistWebInfoHttpGetJsonLastfm
@end

@interface SMArtistWebInfoHttpGetJsonLastfmImages : SMArtistWebInfoHttpGetJsonLastfm
@end

@interface SMArtistWebInfoHttpGetJsonLastfmSimilarity : SMArtistWebInfoHttpGetJsonLastfm
@end

@interface SMArtistWebInfoHttpGetJsonLastfmGenres : SMArtistWebInfoHttpGetJsonLastfm
@end


@implementation SMArtistWebInfoHttpGetJsonLastfm
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

+ (SMArtistWebInfo *)webinfoLastfmWithConfiguration:(SMRootFactory *)theRootFactory withDelegate:(id<SMRequestableDelegate>)theDelegate forRequestType:(SMSingleArtistRequestType)requesttype
{
	SMRateLimitedQueue *queue = [theRootFactory getQueueForLastfm];
	NSAssert(queue != nil, @"undefined queue!");
	
	switch (requesttype) {
        case SMSingleArtistRequestTypeArtistBios:
			return [[SMArtistWebInfoHttpGetJsonLastfmBios alloc] initWithConfiguration:theRootFactory withDelegate:theDelegate withQueue:queue];
			
        case SMSingleArtistRequestTypeArtistSimilarity:
			return [[SMArtistWebInfoHttpGetJsonLastfmSimilarity alloc] initWithConfiguration:theRootFactory withDelegate:theDelegate withQueue:queue];
			
		case SMSingleArtistRequestTypeArtistImages:
			return [[SMArtistWebInfoHttpGetJsonLastfmImages alloc] initWithConfiguration:theRootFactory withDelegate:theDelegate withQueue:queue];
			
		case SMSingleArtistRequestTypeArtistGenres:
			return [[SMArtistWebInfoHttpGetJsonLastfmGenres alloc] initWithConfiguration:theRootFactory withDelegate:theDelegate withQueue:queue];

        default:
			// ignore unsupported request types
            return nil;
    }
}


#pragma mark - Abstract Protected Methods

- (NSString *)extractCorrectedArtistNameFromLastfmDict:(NSDictionary *)responseDict
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)extractFromLastfmDict:(NSDictionary *)responseDict
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

// Get Query String for Last.fm API
- (NSString *)getLastfmQueryStringForMethod:(NSString *)method withParameters:(NSDictionary *)parameters
{
    NSMutableString *getString = [NSMutableString stringWithFormat:@"%@?api_key=%@&format=json&method=%@",
								  self.rootFactory.configuration.lastfmUrl,
								  self.rootFactory.configuration.lastfmKey,
								  method];
    
    for(NSString *key in parameters) {
		NSString *parameter = [parameters objectForKey:key];
		parameter = [parameter sma_urlescape];
		[getString appendFormat:@"&%@=%@",key,parameter];
    }
    
    return getString;
}


#pragma mark - Make Actual Web Request

- (void)doRequestOfType:(SMSingleArtistRequestType)type forMethod:(NSString *)method withParameters:(NSDictionary *)parameters
{
	NSString *requeststring = [self getLastfmQueryStringForMethod:method withParameters:parameters];
	[self doAndProcessHttpUrlRequestForUrl:requeststring];
}


#pragma mark Process and Return Results to Delegate

- (void)processAndSendOutResultWithInfo:(NSDictionary *)theInfo
{
	SMArtistResult *result = [self emptyResult];
	id subinfo = [self extractFromLastfmDict:theInfo];
	result.recognizedArtistName = [self extractCorrectedArtistNameFromLastfmDict:theInfo];
	if (result.recognizedArtistName == nil) {
		result.recognizedArtistName = self.request.artistName;
	}
	[self fillResult:result withInfo:subinfo];
	[self sendOutResult:result];
}


#pragma mark JSON Parsing

- (BOOL)isUnknownArtistErrorInResponse:(NSDictionary *)response
{
	if ([[response sma_stringForKey:@"error"] intValue] == kResponseCodeInvalidParameter &&
		[[response sma_stringForKey:@"message"] rangeOfString:@"artist"].location != NSNotFound &&
		[[response sma_stringForKey:@"message"] rangeOfString:@"found"].location != NSNotFound) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)isErrorInResponse:(NSDictionary *)response
{
	return ([response sma_stringForKey:@"error"] != nil);
}

- (NSString *)errorStringFromResponse:(NSDictionary *)response
{
	return [response sma_stringForKey:@"message"];
}


#pragma mark - Protected Overridden Methods

- (NSTimeInterval)urlRequestTimeoutInterval
{
	return self.rootFactory.configuration.lastfmTimeout;
}

- (void)processJsonResponse:(id)response
{
	if (![response isKindOfClass:[NSDictionary class]]) {
		[self sendOutErrorResultWithErrorString:[NSString stringWithFormat:@"error: could not parse json: %@", [response description]]];
		return;
	}
	
	if ([self isErrorInResponse:response]) {
		if ([self isUnknownArtistErrorInResponse:response]) {
			// that's ok
			[self processAndSendOutResultWithInfo:nil];
		} else {
			[self sendOutErrorResultWithErrorString:[NSString stringWithFormat:@"Last.fm returned error: %@",[self errorStringFromResponse:response]]];
		}
	} else {
		[self processAndSendOutResultWithInfo:response];
	}
}

- (SMArtistWebServices)service
{
	return SMArtistWebServicesLastfm;
}


@end


#pragma mark - Subclasses

@implementation SMArtistWebInfoHttpGetJsonLastfmBios

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
	[self doRequestOfType:SMSingleArtistRequestTypeArtistBios
				forMethod:@"artist.getInfo"
		   withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
						   self.request.artistName,@"artist",
						   @"1",@"autocorrect",
						   nil]
	 ];
}

- (NSString *)extractCorrectedArtistNameFromLastfmDict:(NSDictionary *)responseDict
{
	return [[responseDict sma_dictionaryForKey:@"artist"] sma_stringForKey:@"name"];
}

- (NSArray *)extractFromLastfmDict:(NSDictionary *)responseDict
{
	// {artist{bio{content,summary}}}
    
    NSMutableArray *returnArray = [NSMutableArray array];
    
	NSString *bioLang = @"en"; // TODO request bio in local language and use its ISO 639 alpha-2 code here
    NSString *bioUrl = [[responseDict sma_dictionaryForKey:@"artist"] sma_stringForKey:@"url"];
	bioUrl = [bioUrl stringByAppendingFormat:@"?setlang=%@",bioLang];
    
    NSDictionary *biosDict = [[responseDict sma_dictionaryForKey:@"artist"] sma_dictionaryForKey:@"bio"];
    
    NSString *fullText = [biosDict sma_stringForKey:@"content"];
    NSString *previewText = [biosDict sma_stringForKey:@"summary"];
    
    SMArtistBio *bio = [SMArtistBio artistBioWithUrl:bioUrl withSourceName:@"Last.fm" withPreviewText:previewText withFullText:fullText];
    
    if ([bio isValid]) {
        [returnArray addObject:bio];
    }
    
    return returnArray;
}

@end


@implementation SMArtistWebInfoHttpGetJsonLastfmImages

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
	[self doRequestOfType:SMSingleArtistRequestTypeArtistImages
				forMethod:@"artist.getImages"
		   withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
						   self.request.artistName,@"artist",
						   [NSString stringWithFormat:@"%d",_limit],@"limit",
						   @"1",@"autocorrect",
						   nil]
	 ];
}

- (NSString *)extractCorrectedArtistNameFromLastfmDict:(NSDictionary *)responseDict
{
	return [[[responseDict sma_dictionaryForKey:@"images"] sma_dictionaryForKey:@"@attr"] sma_stringForKey:@"artist"];
}

- (NSArray *)extractFromLastfmDict:(NSDictionary *)responseDict
{
	// {images {image [{sizes {size [{#text}]}}]}} // TODO don't take all of that size
    
    NSMutableArray *returnArray = [NSMutableArray array];
    
    NSArray *imagesArray = [[responseDict sma_dictionaryForKey:@"images"] sma_makeArrayOfObjectForKey:@"image"];
    
	// watch out: when result only has got one artist entry, it is NOT an array but a dict, (e.g. by limit=1) - for this, sma_makeArrayOfObjectForKey is used
	// also, some other strange responses can happen in combination with certain url escaped characters, e.g. artist=Asian%2520Dub%2520Foundation

	for(NSMutableDictionary *imageInfo in imagesArray) {
		if (![imageInfo isKindOfClass:[NSDictionary class]]) {
			NSLog(@"ignoring result: %@", imageInfo);
			continue;
		}

        NSArray *imagesizes = [[imageInfo sma_dictionaryForKey:@"sizes"] sma_arrayForKey:@"size"];
        
        // array's elements hold dict which has attributes:
        // "height" and "width" in pixels
        // "name" name of size, one of "original" (very big, e.g. 981x1121), "large" (e.g. 126x144), "largesquare" (e.g. 126x126), "medium" (e.g. 64x73), "small" (e.g. 34x39), "extralarge" (e.g. 252x288)
		
        for(NSMutableDictionary *imageSize in imagesizes) {
			if (![imageSize isKindOfClass:[NSDictionary class]]) {
				NSLog(@"ignoring result: %@", imageSize);
				continue;
			}
			
            if ([[imageSize sma_stringForKey:@"name"] isEqualToString:@"extralarge"]) {
                NSString *imageUrl = [imageSize sma_stringForKey:@"#text"];
                
                NSString *width = [imageSize sma_stringForKey:@"width"];
                NSString *height = [imageSize sma_stringForKey:@"height"];
                
                CGSize size = CGSizeFromString([NSString stringWithFormat:@"{%@,%@}",width,height]);
                
                SMArtistImage *image = [SMArtistImage artistImageWithUrl:imageUrl withSize:[NSValue valueWithCGSize:size]];
                
                if ([image isValid]) {
                    [returnArray addObject:image];
                }
            }
        }
    }
    
    return returnArray;
}

@end


@implementation SMArtistWebInfoHttpGetJsonLastfmSimilarity

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
	[self doRequestOfType:SMSingleArtistRequestTypeArtistSimilarity
				forMethod:@"artist.getSimilar"
		   withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
						   self.request.artistName,@"artist",
						   [NSString stringWithFormat:@"%d",_limit],@"limit",
						   @"1",@"autocorrect",
						   nil]
	 ];
}

- (NSString *)extractCorrectedArtistNameFromLastfmDict:(NSDictionary *)responseDict
{
	return [[[responseDict sma_dictionaryForKey:@"similarartists"] sma_dictionaryForKey:@"@attr"] sma_stringForKey:@"artist"];
}

- (NSArray *)extractFromLastfmDict:(NSDictionary *)responseDict
{
	// {similarartists [artist {name},{match}]}
    
    NSMutableArray *returnArray = [NSMutableArray array];
    
    NSArray *artistsArray = [[responseDict sma_dictionaryForKey:@"similarartists"] sma_makeArrayOfObjectForKey:@"artist"];
    
    // watch out: when result only has got one artist entry, it is NOT an array but a dict, (e.g. by limit=1) - for this, sma_makeArrayOfObjectForKey is used
	// also, some other strange responses can happen in combination with certain url escaped characters, e.g. artist=Asian%2520Dub%2520Foundation
    
    for(NSMutableDictionary *artistInfo in artistsArray) {
		if (![artistInfo isKindOfClass:[NSDictionary class]]) {
			NSLog(@"ignoring result: %@", artistInfo);
			continue;
		}
        
        NSString *artistName = [artistInfo sma_stringForKey:@"name"];
        
        CGFloat matchValue = [[artistInfo sma_stringForKey:@"match"] floatValue];
		matchValue = fmaxf(0.f, fminf(1.f, matchValue));
        
        SMSimilarArtist *similarArtist = [SMSimilarArtist similarArtistWithName:artistName withMatchValue:matchValue];
        
        if ([similarArtist isValid]) {
            [returnArray addObject:similarArtist];
        }
    }
    
    return returnArray;
}

@end


@implementation SMArtistWebInfoHttpGetJsonLastfmGenres

- (SMArtistResult *)emptyResult {
	return [SMArtistGenresResult result];
}

- (SMSingleArtistRequestType)servingRequestType {
	return SMSingleArtistRequestTypeArtistGenres;
}

- (void)fillResult:(SMArtistGenresResult *)result withInfo:(NSArray *)info {
	SMArtistGenresResult *otherResult = [info objectAtIndex:0];
	result.genres = otherResult.genres;
}

- (void)doRequest {
	[self doRequestOfType:SMSingleArtistRequestTypeArtistGenres
				forMethod:@"artist.getInfo"
		   withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
						   self.request.artistName,@"artist",
						   @"1",@"autocorrect",
						   nil]
	 ];
}

- (NSString *)extractCorrectedArtistNameFromLastfmDict:(NSDictionary *)responseDict {
	return [[responseDict sma_dictionaryForKey:@"artist"] sma_stringForKey:@"name"];
}

- (NSArray *)extractFromLastfmDict:(NSDictionary *)responseDict {
    
    NSDictionary *dict = [[responseDict sma_dictionaryForKey:@"artist"] sma_dictionaryForKey:@"tags"];
	
	SMArtistGenresResult *result = [[SMArtistGenresResult alloc] init];
	
	if([dict isKindOfClass:[NSDictionary class]]) {
		id values = [[dict valueForKey:@"tag"] valueForKey:@"name"];
		result.genres = [NSArray arrayWithArrayOrObject:values];
	}
	else {
		result.error = [NSError errorWithDomain:@"SMArtist" code:1 userInfo:nil];
	}

    return @[result];
}

@end

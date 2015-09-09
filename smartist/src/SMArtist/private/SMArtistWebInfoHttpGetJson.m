//
//  SMArtistWebInfoHttpGetJson.m
//  SMArtist
//
//  Created by Fabian on 31.01.12.
//  Copyright (c) 2012 Spectralmind. All rights reserved.
//

#import "SMArtistWebInfoHttpGetJson.h"
#import "SMArtistWebInfo+Private.h"
#import "SMArtistWebInfoTimeMeasurement.h"

#import "SMRootFactory.h"


@implementation SMArtistWebInfoHttpGetJson
{
@private
    NSURLConnection *_urlConnection;
    NSMutableData *_responseData;
    SMArtistWebInfoTimeMeasurement *_timeMeasurement;
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
        _timeMeasurement = [[SMArtistWebInfoTimeMeasurement alloc] init];
    }
    
    return self;
}


#pragma mark - Protected Overridden Methods

- (void)setResultDetails:(SMArtistResult *)result {
	result.info = [NSDictionary dictionaryWithObject:[NSArray arrayWithArray:_timeMeasurement.timesTaken] forKey:@"time taken"];
	[super setResultDetails:result];
}


#pragma mark - Abstract Protected Methods

- (NSTimeInterval)urlRequestTimeoutInterval
{
	[self doesNotRecognizeSelector:_cmd];
	return 0;
}

- (void)processJsonResponse:(id)response
{
	[self doesNotRecognizeSelector:_cmd];
}



#pragma mark Make Actual Web Request

- (void)doAndProcessHttpUrlRequestForUrl:(NSString *)url
{
    [_timeMeasurement startTimeMeasurement];
	_responseData = [NSMutableData data];
	[_timeMeasurement setTimeMeasurePointForNow:@"url request setoff"];
	
	// don't cache at all, additionally provide protocol method connection:willCacheResponse:
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:[self urlRequestTimeoutInterval]];
	// default: NSURLRequestUseProtocolCachePolicy
	
	_urlConnection = [[self.rootFactory urlconnectionFactory] newUrlConnectionWithRequest:request withDelegate:self];
}


#pragma mark JSON Parsing

- (void)handleWebserviceResponse:(NSData *)response
{
	__autoreleasing NSError* error = nil;
    id info = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
	
	if (error != nil) {
        [self sendOutErrorResultWithError:error];
    } else {
        [_timeMeasurement setTimeMeasurePointForNow:@"parse finished"];
		[self processJsonResponse:info];
    }
	
	[_timeMeasurement endTimeMeasurement];
}


#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [httpResponse statusCode];
    if (403 == statusCode || 404 == statusCode || 500 <= statusCode) {
        [connection cancel];
        NSString *errorString = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
        [self sendOutErrorResultWithErrorString:errorString];
    } else {
        [_responseData setLength:0];
        [_timeMeasurement setTimeMeasurePointForNow:@"url response"];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self sendOutErrorResultWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [_timeMeasurement setTimeMeasurePointForNow:@"receiving finished"];
    [self handleWebserviceResponse:_responseData];
}

// don't cache
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}


@end

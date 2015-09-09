//
//  SMArtistMerger.m
//  SMArtist
//
//  Created by Fabian on 23.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//

#import "SMArtistMerger.h"

//#import "ArtistWebInfoResult.h"

#import "SMRootFactory.h"
#import "SMResultCache.h"

#import "SMArtistSimilarityResult.h"
#import "SMArtistSimilarityMatrixResult.h"
#import "SMArtistBiosResult.h"
#import "SMArtistImagesResult.h"

@interface SMArtistMerger ()
@property (nonatomic, strong) NSMutableArray *outstandingRequests;
@property (nonatomic, strong) NSMutableArray *results;

- (void)removeOutstandingRequestable:(SMRequestable *)requestable;

- (void)addResult:(SMArtistResult *)result;

- (NSArray *)allResults;

- (BOOL)requestsComplete;

- (void)returnIfFinished;

- (BOOL)resultCacheableForSubresults:(NSArray *)results;

- (BOOL)returnCachedResult:(SMArtistResult *)result;

- (void)allResultsReceived;

- (void)sendOutArtistResult:(SMArtistResult *)result;

@end


@implementation SMArtistMerger
{
	@private
	SMArtistRequest *request;
    NSMutableArray *outstandingRequests;
    NSMutableArray *results;
	id resultClass;
	SMResultCache *cache;
}

@synthesize request, outstandingRequests, results;

- (id)init
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)initWithConfiguration:(SMRootFactory *)theConfigfactory withDelegate:(id<SMRequestableDelegate>)theDelegate 
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)initWithConfiguration:(SMRootFactory *)theConfigfactory withDelegate:(id<SMRequestableDelegate>)theDelegate resultClass:(id)theResultClass cache:(SMResultCache *)theCache
{
    self = [super initWithConfiguration:theConfigfactory withDelegate:theDelegate];
    if (self) {
        // Initialization code here.
        self.outstandingRequests = [NSMutableArray array];
        self.results = [NSMutableArray array];
		resultClass = theResultClass;
		cache = theCache;
    }
    
    return self;
}


#pragma mark - Protected Helper Methods

- (void)removeOutstandingRequestable:(SMRequestable *)requestable
{
	@synchronized(self) {
		[self.outstandingRequests removeObject:requestable];
	}
}

- (void)addResult:(SMArtistResult *)result
{
	@synchronized(self) {
		[self.results addObject:result];
	}
}

- (BOOL)requestsComplete
{
	@synchronized(self) {
		return self.outstandingRequests.count == 0;
	}
}

- (NSArray *)allResults
{
	@synchronized(self) {
		return self.results;
	}
}


- (BOOL)returnCachedResult:(SMArtistResult *)result {
	if([result class] != resultClass) {
		return false;
	}
	
	NSAssert(result.cacheable == NO, @"Cached result should not be cacheable");

	[self sendOutArtistResult:result];
	return true;
}

- (void)allResultsReceived
{
    SMArtistResult *result = [[resultClass alloc] initWithResults:[self allResults]];
    [self sendOutArtistResult:result];
}

- (void)returnIfFinished
{
	if ([self requestsComplete]) {
        //NSLog(@"requestsComplete - returning");
        [self allResultsReceived];
    }
}

- (BOOL)resultCacheableForSubresults:(NSArray *)theResults
{
	for (SMArtistResult *res in theResults) {
		if (res.cacheable == NO || res.error != nil) {
			return NO;
		}
	}
	return YES;
}

- (void)finalizeResult:(SMArtistResult *)result
{
	result.clientId = self.request.clientId;
	result.request = self.request;
	if (result.cacheable) {
		[cache storeResult:result forCacheId:[request cachingId]];
	}
}

- (void)sendOutArtistResult:(SMArtistResult *)result
{
	[self finalizeResult:result];
    [self.delegate doneSMRequestWithRequestable:self withResult:result];
}

#pragma mark - Public Web Query Methods

- (void)startRequest {
	[self.outstandingRequests removeAllObjects];

	SMArtistResult *cacheresult = [cache resultForCacheId:[request cachingId]];
    if (cacheresult != nil) {
		//NSLog(@"cached result found: %@",cacheresult);
		if([self returnCachedResult:cacheresult]) {
			return;
		}
		
		NSLog(@"corrupted cache item of type %@ for id %@ removed!", [cacheresult class], [request cachingId]);
		// corrupted cache item. delete it and start over.
		[cache removeResultForCacheId:[request cachingId]];
	}
	
	[self.outstandingRequests addObjectsFromArray:[self.request requestablesWithDelegate:self]];

	[self returnIfFinished];

	for (SMRequestable *requestable in [NSArray arrayWithArray:self.outstandingRequests]) {
		[requestable startRequest];
	}
}


#pragma mark - Abstract SMRequestableDelegate Methods

- (void)doneSMRequestWithRequestable:(SMRequestable *)requestable withResult:(SMArtistResult *)theResult
{
    [self addResult:theResult];
    [self removeOutstandingRequestable:requestable];
    //NSLog(@"doneWebRequestWithArtistResult");
	[self returnIfFinished];
}


@end

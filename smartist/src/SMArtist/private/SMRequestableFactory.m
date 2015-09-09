//
//  SMRequestableFactory.m
//  SMArtist
//
//  Created by Fabian on 01.02.12.
//  Copyright (c) 2012 Spectralmind. All rights reserved.
//

#import "SMRequestableFactory.h"

#import "SMArtistBiosResult.h"
#import "SMArtistGenresResult.h"
#import "SMArtistImagesResult.h"
#import "SMArtistMerger.h"
#import "SMArtistSimilarityMatrixResult.h"
#import "SMArtistSimilarityResult.h"
#import "SMArtistVideosResult.h"
#import "SMResultCache.h"
#import "SMRootFactory.h"

@implementation SMRequestableFactory {
    SMRootFactory *__weak rootFactory;
	SMResultCache *cache;
}

@synthesize rootFactory;

- (id)initWithCache:(SMResultCache *)theCache
{
    self = [super init];
    if (self) {
        cache = theCache;
    }
    return self;
}



- (SMRequestable *)artistBiosRequestableForArtistName:(NSString *)artistName withClientId:(id)clientId delegate:(id<SMRequestableDelegate>)delegate priority:(BOOL)priority {
    //NSLog(@"%@ bio requested",artistName);
	SMArtistMerger *merger = [self mergerWithDelegate:delegate resultClass:[SMArtistBiosResult class]];
	merger.request = [[self.rootFactory requestFactory] artistBiosRequestWithClientId:clientId withArtistName:artistName priority:priority];
	return merger;
}

- (SMRequestable *)artistSimilarityRequestableForArtistName:(NSString *)artistName withClientId:(id)clientId delegate:(id<SMRequestableDelegate>)delegate priority:(BOOL)priority {
    //NSLog(@"%@ similarity requested",artistName);
	SMArtistMerger *merger = [self mergerWithDelegate:delegate resultClass:[SMArtistSimilarityResult class]];
	merger.request = [[self.rootFactory requestFactory] artistSimilarityRequestWithClientId:clientId withArtistName:artistName priority:priority];
	return merger;
}

- (SMRequestable *)artistSimilarityMatrixRequestableForArtistNames:(NSArray *)artistNames withClientId:(id)clientId delegate:(id<SMRequestableDelegate>)delegate priority:(BOOL)priority {
	//NSLog(@"similarity matrix requested for artists: %@",artistNames);
	SMArtistMerger *merger = [self mergerWithDelegate:delegate resultClass:[SMArtistSimilarityMatrixResult class]];
	merger.request = [[self.rootFactory requestFactory] artistSimilarityMatrixRequestWithClientId:clientId withArtistNames:artistNames priority:priority];
	return merger;
}

- (SMRequestable *)artistImagesRequestableForArtistName:(NSString *)artistName withClientId:(id)clientId delegate:(id<SMRequestableDelegate>)delegate priority:(BOOL)priority {
    //NSLog(@"%@ images requested",artistName);
	SMArtistMerger *merger = [self mergerWithDelegate:delegate resultClass:[SMArtistImagesResult class]];
	merger.request = [[self.rootFactory requestFactory] artistImagesRequestWithClientId:clientId withArtistName:artistName priority:priority];
	return merger;
}

- (SMRequestable *)artistGenresRequestableForArtistName:(NSString *)artistName withClientId:(id)clientId delegate:(id<SMRequestableDelegate>)delegate priority:(BOOL)priority {
    //NSLog(@"%@ videos requested",artistName);
	SMArtistMerger *merger = [self mergerWithDelegate:delegate resultClass:[SMArtistGenresResult class]];
	merger.request = [[self.rootFactory requestFactory] artistGenresRequestWithClientId:clientId withArtistName:artistName priority:priority];
	return merger;
}

- (SMRequestable *)artistVideosRequestableForArtistName:(NSString *)artistName withClientId:(id)clientId delegate:(id<SMRequestableDelegate>)delegate priority:(BOOL)priority {
    //NSLog(@"%@ videos requested",artistName);
	SMArtistMerger *merger = [self mergerWithDelegate:delegate resultClass:[SMArtistVideosResult class]];
	merger.request = [[self.rootFactory requestFactory] artistVideosRequestWithClientId:clientId withArtistName:artistName priority:priority];
	return merger;
}

- (SMArtistMerger *)mergerWithDelegate:(id<SMRequestableDelegate>)delegate resultClass:(id)resultClass {
    return [[SMArtistMerger alloc] initWithConfiguration:self.rootFactory withDelegate:delegate resultClass:resultClass cache:cache];
}


@end

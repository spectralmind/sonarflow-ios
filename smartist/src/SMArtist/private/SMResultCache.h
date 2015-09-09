//
//  SMResultCache.h
//  SMArtist
//
//  Created by Manuel Maly on 13.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMArtistResult;

@interface SMResultCache : NSObject

- (id)initWithMaximumAge:(NSTimeInterval)theMaximumAge;

- (SMArtistResult *)resultForCacheId:(NSString *)cacheId;
- (SMArtistResult *)resultForCacheId:(NSString *)cacheId allowExpired:(BOOL)expiredOk;
- (void)storeResult:(SMArtistResult *)result forCacheId:(NSString *)cacheId;

- (void)pruneExpired;
- (void)clear;

- (BOOL)removeResultForCacheId:(NSString *)cacheId;

@end

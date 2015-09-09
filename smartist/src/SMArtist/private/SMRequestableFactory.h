//
//  SMRequestableFactory.h
//  SMArtist
//
//  Created by Fabian on 01.02.12.
//  Copyright (c) 2012 Spectralmind. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SMRequestable.h"

@class SMRootFactory;
@class SMResultCache;

@interface SMRequestableFactory : NSObject

@property (nonatomic, weak) SMRootFactory *rootFactory;


- (id)initWithCache:(SMResultCache *)theCache;

- (SMRequestable *)artistBiosRequestableForArtistName:(NSString *)artistName withClientId:(id)clientId delegate:(id<SMRequestableDelegate>)delegate priority:(BOOL)priority;

- (SMRequestable *)artistSimilarityRequestableForArtistName:(NSString *)artistName withClientId:(id)clientId delegate:(id<SMRequestableDelegate>)delegate priority:(BOOL)priority;

- (SMRequestable *)artistSimilarityMatrixRequestableForArtistNames:(NSArray *)artistNames withClientId:(id)clientId delegate:(id<SMRequestableDelegate>)delegate priority:(BOOL)priority;

- (SMRequestable *)artistImagesRequestableForArtistName:(NSString *)artistName withClientId:(id)clientId delegate:(id<SMRequestableDelegate>)delegate priority:(BOOL)priority;

- (SMRequestable *)artistGenresRequestableForArtistName:(NSString *)artistName withClientId:(id)clientId delegate:(id<SMRequestableDelegate>)delegate priority:(BOOL)priority;

- (SMRequestable *)artistVideosRequestableForArtistName:(NSString *)artistName withClientId:(id)clientId delegate:(id<SMRequestableDelegate>)delegate priority:(BOOL)priority;

@end

//
//  SMRootFactory.h
//  SMArtist
//
//  Created by Fabian on 06.09.11.
//  Copyright (c) 2011 Spectralmind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMArtistConfiguration.h"
#import "SMUrlConnectionFactory.h"
#import "SMRequestableFactory.h"
#import "SMWebInfoFactory.h"
#import "SMArtistRequestFactory.h"

@interface SMRootFactory : NSObject

- (id)initWithConfiguration:(SMArtistConfiguration *)configuration;

@property (nonatomic, strong) SMArtistConfiguration *configuration;
@property (nonatomic, readonly) SMResultCache *cache;

- (SMArtistRequestFactory *)requestFactory;

- (SMRequestableFactory *)requestableFactory;

- (SMWebInfoFactory *)webinfoFactory;

- (SMUrlConnectionFactory *)urlconnectionFactory;

- (SMRateLimitedQueue *)getQueueForYoutube;
- (SMRateLimitedQueue *)getQueueForEchonest;
- (SMRateLimitedQueue *)getQueueForLastfm;

@end

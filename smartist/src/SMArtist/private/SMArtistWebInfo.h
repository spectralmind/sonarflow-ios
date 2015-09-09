//
//  SMArtistWebInfo.h
//  SMArtist
//
//  Created by Fabian on 17.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//
// ABSTRACT Web Service Fetcher Class
//
// 

#import <UIKit/UIKit.h>
#import "SMRequestable.h"
#import "SMArtistRequest.h"
#import "SMArtistResult.h"
#import "SMArtistResult+Private.h"

#import "SMSingleArtistRequest.h"

@class SMRootFactory;
@class SMRateLimitedQueue;

// ABSTRACT
@interface SMArtistWebInfo : SMRequestable

+ (SMArtistWebInfo *)webinfoWithConfiguration:(SMRootFactory *)theRootFactory withDelegate:(id<SMRequestableDelegate>)theDelegate ForWebservice:(SMArtistWebServices)webservice forRequestType:(SMSingleArtistRequestType)requesttype;

@property (nonatomic, strong) SMSingleArtistRequest *request;

- (id)initWithConfiguration:(SMRootFactory *)theConfigfactory withDelegate:(id<SMRequestableDelegate>)theDelegate withQueue:(SMRateLimitedQueue *)theQueue;

- (SMArtistWebServices)service;

@end


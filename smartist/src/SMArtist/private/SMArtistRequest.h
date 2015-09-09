//
//  WebInfoRequest.h
//  SMArtist
//
//  Created by Fabian on 22.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SMArtistConfiguration.h"

@class SMRootFactory;
@protocol SMRequestableDelegate;

/*!
 @class SMArtistRequest
 
 @abstract A SMArtistRequest object capsulates information about a web request.
 
 @discussion SMArtistRequest contains MORE information than the client provided when doing its query.
    Implicit parameters like result limit are also contained.
 */
@interface SMArtistRequest : NSObject


- (id)initWithClientId:(id)theClientId servicesMask:(SMArtistWebServices)theServicesMask
		 configFactory:(SMRootFactory *)theConfigFactory;

/*!
 @property clientId
 @abstract Any id provided by the client.
 */
@property (nonatomic, strong) id clientId;

/*!
 @property servicesMask
 @abstract The used web services for this request.
 */
@property (nonatomic, assign) SMArtistWebServices servicesMask;

@property (weak, nonatomic, readonly) SMRootFactory *configFactory;

@property (nonatomic, assign) BOOL priority;

- (NSArray *)requestablesWithDelegate:(id<SMRequestableDelegate>)delegate;

- (NSString *)cachingId;

@end

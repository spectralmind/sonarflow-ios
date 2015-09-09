//
//  SMRequestable.h
//  SMArtist
//
//  Created by Fabian on 06.12.11.
//  Copyright (c) 2011 Spectralmind. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SMRequestable.h"
#import "SMArtistRequest.h"

#import "SMArtistBiosResult.h"
#import "SMArtistSimilarityResult.h"
#import "SMArtistSimilarityMatrixResult.h"
#import "SMArtistImagesResult.h"

@protocol SMRequestableDelegate;
@class SMRootFactory;

@interface SMRequestable : NSObject

- (id)initWithConfiguration:(SMRootFactory *)theConfigfactory withDelegate:(id<SMRequestableDelegate>)theDelegate;

@property (nonatomic, weak) SMRootFactory *rootFactory;
@property (nonatomic, weak) id<SMRequestableDelegate> delegate;

- (void)startRequest;

@end


@protocol SMRequestableDelegate <NSObject>

@required

- (void)doneSMRequestWithRequestable:(SMRequestable *)requestable withResult:(SMArtistResult *)theResult;

@end

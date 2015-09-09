//
//  SMArtistRequestFactory.h
//  SMArtist
//
//  Created by Fabian on 25.11.11.
//  Copyright (c) 2011 Spectralmind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMArtistRequest.h"

@class SMRootFactory;

@interface SMArtistRequestFactory : NSObject

@property (nonatomic, weak) SMRootFactory *rootFactory;

- (SMArtistRequest *)artistBiosRequestWithClientId:(id)clientId withArtistName:(NSString *)artistName priority:(BOOL)priority;

- (SMArtistRequest *)artistSimilarityRequestWithClientId:(id)clientId withArtistName:(NSString *)artistName priority:(BOOL)priority;

- (SMArtistRequest *)artistSimilarityMatrixRequestWithClientId:(id)clientId withArtistNames:(NSArray *)artistNames priority:(BOOL)priority;

- (SMArtistRequest *)artistImagesRequestWithClientId:(id)clientId withArtistName:(NSString *)artistName priority:(BOOL)priority;

- (SMArtistRequest *)artistVideosRequestWithClientId:(id)clientId withArtistName:(NSString *)artistName priority:(BOOL)priority;

- (SMArtistRequest *)artistGenresRequestWithClientId:(id)clientId withArtistName:(NSString *)artistName priority:(BOOL)priority;

@end

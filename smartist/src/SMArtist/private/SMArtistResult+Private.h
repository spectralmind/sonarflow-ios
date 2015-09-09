//
//  SMArtistResult+Private.h
//  SMArtist
//
//  Created by Fabian on 02.12.11.
//  Copyright (c) 2011 Spectralmind. All rights reserved.
//

#import "SMArtistResult.h"

@class SMArtistRequest;

@interface SMArtistResult () <NSCoding>

@property (nonatomic, strong) SMArtistRequest *request;
@property (nonatomic, assign) SMArtistWebServices servicesUsedMask;
@property (nonatomic, assign) BOOL cacheable;

- (void)mergeProperties:(SMArtistResult *)result;

@end
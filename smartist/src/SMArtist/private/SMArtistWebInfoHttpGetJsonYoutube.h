//
//  SMArtistWebInfoHttpGetJsonYoutube.h
//  SMArtist
//
//  Created by Fabian on 01.02.12.
//  Copyright (c) 2012 Spectralmind. All rights reserved.
//

#import "SMArtistWebInfoHttpGetJson.h"

@interface SMArtistWebInfoHttpGetJsonYoutube : SMArtistWebInfoHttpGetJson

+ (SMArtistWebInfo *)webinfoYoutubeWithConfiguration:(SMRootFactory *)theConfigfactory withDelegate:(id<SMRequestableDelegate>)theDelegate forRequestType:(SMSingleArtistRequestType)requesttype;

- (id)initWithConfiguration:(SMRootFactory *)rootFactory withDelegate:(id<SMRequestableDelegate>)delegate withQueue:(SMRateLimitedQueue *)theQueue;

@end

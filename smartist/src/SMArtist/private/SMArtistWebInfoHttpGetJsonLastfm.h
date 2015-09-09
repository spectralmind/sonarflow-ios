//
//  SMArtistWebInfoLastfm.h
//  SMArtist
//
//  Created by Fabian on 19.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//

#import "SMArtistWebInfoHttpGetJson.h"

@interface SMArtistWebInfoHttpGetJsonLastfm : SMArtistWebInfoHttpGetJson <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

+ (SMArtistWebInfo *)webinfoLastfmWithConfiguration:(SMRootFactory *)theRootFactory withDelegate:(id<SMRequestableDelegate>)theDelegate forRequestType:(SMSingleArtistRequestType)requesttype;

- (id)initWithConfiguration:(SMRootFactory *)rootFactory withDelegate:(id<SMRequestableDelegate>)delegate withQueue:(SMRateLimitedQueue *)theQueue;

@end

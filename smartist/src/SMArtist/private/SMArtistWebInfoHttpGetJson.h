//
//  SMArtistWebInfoHttpGetJson.h
//  SMArtist
//
//  Created by Fabian on 31.01.12.
//  Copyright (c) 2012 Spectralmind. All rights reserved.
//

#import "SMArtistWebInfo.h"

// ABSTRACT
@interface SMArtistWebInfoHttpGetJson : SMArtistWebInfo <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

- (id)initWithConfiguration:(SMRootFactory *)rootFactory withDelegate:(id<SMRequestableDelegate>)delegate withQueue:(SMRateLimitedQueue *)theQueue;

@end

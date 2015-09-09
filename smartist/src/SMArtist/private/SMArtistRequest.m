//
//  SMArtistRequest.m
//  SMArtist
//
//  Created by Fabian on 22.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//

#import "SMArtistRequest.h"
#import "SMRequestable.h"
#import "SMRootFactory.h"

@implementation SMArtistRequest {
	id clientId;
    SMArtistWebServices servicesMask;
	SMRootFactory *__weak configFactory;
}

@synthesize clientId;
@synthesize servicesMask;
@synthesize configFactory;

- (id)initWithClientId:(id)theClientId servicesMask:(SMArtistWebServices)theServicesMask
		 configFactory:(SMRootFactory *)theConfigFactory
{
    self = [super init];
    if (self) {
		self.clientId = theClientId;
		self.servicesMask = theServicesMask;
		configFactory = theConfigFactory;
    }
    return self;
}


- (NSString *)cachingId {
    NSMutableString *cachingId = [NSMutableString string];
    [cachingId appendFormat:@"%i", servicesMask];
    return cachingId;
}

- (NSArray *)requestablesWithDelegate:(id<SMRequestableDelegate>)delegate {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

@end

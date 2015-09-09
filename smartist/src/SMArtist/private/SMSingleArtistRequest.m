//
//  SMSingleArtistRequest.m
//  SMArtist
//
//  Created by Raphael Charwot on 15.02.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "SMSingleArtistRequest.h"
#import "SMRootFactory.h"

@implementation SMSingleArtistRequest {
	NSString *artistName;
	SMSingleArtistRequestType type;
}

@synthesize artistName, type;

- (id)initWithArtistName:(NSString *)theArtistName requestType:(SMSingleArtistRequestType)theType
				clientId:(id)theClientId servicesMask:(SMArtistWebServices)theServicesMask
		   configFactory:(SMRootFactory *)theConfigFactory {
    self = [super initWithClientId:theClientId servicesMask:theServicesMask configFactory:theConfigFactory];
    if (self) {
		artistName = theArtistName;
		type = theType;
    }
    return self;
}


- (NSArray *)requestablesWithDelegate:(id<SMRequestableDelegate>)delegate {
	return [[self.configFactory webinfoFactory] webInfosWithDelegate:delegate forRequest:self];
}

- (NSString *)cachingId {
	NSMutableString *cachingId = [[super cachingId] mutableCopy];
	[cachingId appendString:self.artistName];
	[cachingId appendFormat:@"%lu", (unsigned long) self.type];

	return cachingId;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Request Type: %d\nArtist name: %@\nServices: %d",
			self.type, self.artistName, self.servicesMask];
}

@end

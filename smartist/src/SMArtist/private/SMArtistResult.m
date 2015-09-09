//
//  SMArtistResult.m
//  SMArtist
//
//  Created by Fabian on 22.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//

#import "SMArtistResult.h"
#import "SMArtistResult+Private.h"
#import "SMArtistRequest.h"

#define kRecognizedArtistName @"recognizedArtistName"
#define kServicesUsedMask @"servicesUsedMask"

@implementation SMArtistResult
{
@private
    id clientId;
	NSString *recognizedArtistName;
    NSError *error;
	
    NSDictionary *info;
	
	SMArtistRequest *request;
	SMArtistWebServices servicesUsedMask;
	BOOL cacheable;
}

@synthesize clientId;
@synthesize recognizedArtistName;
@synthesize info, error;

@synthesize request;
@synthesize servicesUsedMask;
@synthesize cacheable;


- (id)init
{
    self = [super init];
    if (self) {
		self.cacheable = YES;
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:recognizedArtistName forKey:kRecognizedArtistName];
    [encoder encodeInteger:servicesUsedMask forKey:kServicesUsedMask];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (self) {
        self.recognizedArtistName = [decoder decodeObjectForKey:kRecognizedArtistName];
        self.servicesUsedMask = [decoder decodeIntegerForKey:kServicesUsedMask];
    }
    return self;
}

- (void)mergeProperties:(SMArtistResult *)result {
	NSAssert([result isKindOfClass:[self class]], @"result of wrong type encountered");

	if (self.recognizedArtistName == nil ||
		(result.servicesUsedMask & SMArtistWebServicesLastfm) > 0) {
		self.recognizedArtistName = result.recognizedArtistName;
	}
	if (result.error) {
		self.error = result.error;
		self.cacheable = NO;
	}
	if(result.cacheable == NO) {
		self.cacheable = NO;
	}
}

@end

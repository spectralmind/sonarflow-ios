//
//  SMArtistSimilarityMatrixRequest.m
//  SMArtist
//
//  Created by Raphael Charwot on 15.02.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "SMArtistSimilarityMatrixRequest.h"
#import "SMRequestable.h"
#import "SMRootFactory.h"

@interface SMArtistSimilarityMatrixRequest ()

@property (strong, nonatomic, readonly) NSArray *artistNames;

@end


@implementation SMArtistSimilarityMatrixRequest {
	NSArray *artistNames;
}

@synthesize artistNames;

- (id)initWithArtistNames:(NSArray *)theArtistNames clientId:(id)theClientId
				 services:(SMArtistWebServices)theServicesMask
			configFactory:(SMRootFactory *)theConfigFactory {
    self = [super initWithClientId:theClientId servicesMask:theServicesMask configFactory:theConfigFactory];
    if (self) {
		artistNames = theArtistNames;
    }
    return self;
}


- (NSArray *)requestablesWithDelegate:(id<SMRequestableDelegate>)delegate {
	NSMutableArray *requestables = [NSMutableArray arrayWithCapacity:[self.artistNames count]];
	for (NSString *artistName in self.artistNames) {
		SMRequestable *requestable = [[self.configFactory requestableFactory] artistSimilarityRequestableForArtistName:artistName withClientId:nil delegate:delegate priority:NO];
		[requestables addObject:requestable];
	}
	
	return requestables;
}

- (NSString *)cachingId {
    NSMutableString *cachingId = [[super cachingId] mutableCopy];
	NSArray *sortedArtistNames = [self.artistNames sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	for (NSString *name in sortedArtistNames) {
		[cachingId appendString:name];
	}
	
	return cachingId;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Similarity Matrix Request:\nArtist names: %@\nServices: %d",
			self.artistNames, self.servicesMask];
}


@end

//
//  DiscoveryResultMerger.m
//  sonarflow
//
//  Created by Arvid Staub on 26.04.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "DiscoveryResultMerger.h"
#import "SMArtist.h"
#import "DiscoveryZone.h"

@interface DiscoveryResultMerger()
@property (nonatomic, strong) NSSet *discoveredSimilarArtists;
@end

@implementation DiscoveryResultMerger {
	int expectedResults;
	int receivedResults;
	
	NSSet *discoveredSimilarArtists;
	NSObject<DiscoveryResultDelegate> *delegate;
	DiscoveryZone *queryZone;
}

@synthesize discoveredSimilarArtists;
@synthesize queryZone;

- (id)init {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)initWithExpectedResultCount:(int)results andDelegate:(NSObject<DiscoveryResultDelegate> *)theDelegate {
    self = [super init];
    if (self) {
        expectedResults = results;
		receivedResults = 0;
		discoveredSimilarArtists = [[NSSet alloc] init];
		delegate = theDelegate;
    }
	
    return self;
}


- (void)incorporateResult:(SMArtistSimilarityResult *)result {
	
	for(SMSimilarArtist *artist in result.similarArtists) {
		SMSimilarArtist *sameResult = [self.discoveredSimilarArtists member:artist];								   
		
		if(sameResult != nil) {
			sameResult.matchValue += artist.matchValue + 1.0;
			NSLog(@"discovery merger: duplicate similar artist: %@", sameResult.artistName);
		}
		else {
			self.discoveredSimilarArtists = [self.discoveredSimilarArtists setByAddingObject:artist];
		}
	}
	
	++receivedResults;
	NSLog(@"merger: received result %d of %d", receivedResults, expectedResults);
	if(receivedResults == expectedResults) {
		[self returnResultsByDelegate];
	}
}

- (void)returnResultsByDelegate {
	NSArray *sorting = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"matchValue" ascending:NO]];
	
	NSArray *result = [discoveredSimilarArtists sortedArrayUsingDescriptors:sorting];

	[delegate doneWithSimilarityQuery:result fromZone:self.queryZone];
}

@end

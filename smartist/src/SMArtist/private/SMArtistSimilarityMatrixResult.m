//
//  SMArtistSimilarityMatrixResult.m
//  SMArtist
//
//  Created by Fabian on 09.12.11.
//  Copyright (c) 2011 Spectralmind. All rights reserved.
//

#import "SMArtistSimilarityMatrixResult.h"
#import "SMArtistResult+Private.h"
#import "SMArtistSimilarityResult.h"
#import "SMSingleArtistRequest.h"

#define kSimilarityMatrix @"sm"
#define kMatchedArtistNames @"an"

@interface SMArtistSimilarityMatrixResult ()

- (void)setCombinedResults:(NSArray *)results;
- (void)removeUnneededArtistsFromMatrix:(NSMutableDictionary *)similarArtistMatrix;

@end


@implementation SMArtistSimilarityMatrixResult
{
@private
    NSDictionary *similarityMatrix;
	NSDictionary *matchedArtistNames;
}

@synthesize similarityMatrix;
@synthesize matchedArtistNames;

+ (SMArtistSimilarityMatrixResult *)result
{
    SMArtistSimilarityMatrixResult *empty = [[SMArtistSimilarityMatrixResult alloc] init];
    return empty;
}
- (id)init
{
	return [self initWithResults:nil];
}

- (id)initWithResults:(NSArray *)results {
    self = [super init];
    if (self) {
		[self setCombinedResults:results];
    }
    
    return self;
}

- (void)setCombinedResults:(NSArray *)results {
	NSMutableDictionary *similarArtistMatrix = [NSMutableDictionary dictionaryWithCapacity:[results count]];
    NSMutableDictionary *matchedArtistNamesMatrix = [NSMutableDictionary dictionaryWithCapacity:[results count]];

    for (SMArtistSimilarityResult *result in results) {
		NSAssert([result isKindOfClass:[SMArtistSimilarityResult class]], @"result of wrong type encountered");
        if (result.error) {
			self.error = result.error;
        }
		
		SMSingleArtistRequest *resultRequest = (SMSingleArtistRequest *)result.request;
		NSAssert([resultRequest isKindOfClass:[SMSingleArtistRequest class]], @"Unexpected request class");
		
		if (result.error || result.recognizedArtistName == nil || resultRequest.artistName == nil) {
			NSLog(@"warning: ignoring erroneous result: %@",[result description]);
			continue;
		}
		
		[matchedArtistNamesMatrix setValue:result.recognizedArtistName forKey:resultRequest.artistName];
		
		NSMutableDictionary *similarArtists = [NSMutableDictionary dictionaryWithCapacity:[result.similarArtists count]];
		for (SMSimilarArtist *simart in result.similarArtists) {
			[similarArtists setValue:[NSNumber numberWithFloat:simart.matchValue] forKey:simart.artistName];
		}
		
		[similarArtistMatrix setValue:similarArtists forKey:result.recognizedArtistName];
    }
	
	[self removeUnneededArtistsFromMatrix:similarArtistMatrix];
	
	self.similarityMatrix = similarArtistMatrix;
	self.matchedArtistNames = matchedArtistNamesMatrix;
	
	//ignore cacheability of subresults to also allow to cache this result if it is composed from cached subresults
    self.cacheable = (self.error == nil);
}

- (void)removeUnneededArtistsFromMatrix:(NSMutableDictionary *)similarArtistMatrix
{
    for (NSString *key1 in similarArtistMatrix) {
		NSMutableDictionary *similars = [similarArtistMatrix objectForKey:key1];
		for (NSString *key2 in [NSDictionary dictionaryWithDictionary:similars]) {
			if ([similarArtistMatrix objectForKey:key2] == nil) {
				[similars removeObjectForKey:key2];
			} else {
				//NSLog(@"Thrown out unneeded artist %@",simart.artistName);
			}
		}
	}
}



- (NSString *)description
{
    NSMutableString *desc = [NSMutableString stringWithString:@"SMArtistSimilarityMatrixResult with Similarity Matrix:\n"];
    
	for (NSString *key1 in self.similarityMatrix) {
        [desc appendFormat:@"\n\nFrom %@:\n\n",key1];
		for (NSString *key2 in [self.similarityMatrix objectForKey:key1]) {
			[desc appendFormat:@"  to %@: %@\n",key2,[[self.similarityMatrix objectForKey:key1] objectForKey:key2]];
		}
    }

	[desc appendFormat:@"\n\nand with matched artist names:\n\n"];
	
	for (NSString *key in self.matchedArtistNames) {
		[desc appendFormat:@"  \"%@\" = \"%@\"\n",key,[self.matchedArtistNames objectForKey:key]];
	}

    return desc;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:similarityMatrix forKey:kSimilarityMatrix];
    [encoder encodeObject:matchedArtistNames forKey:kMatchedArtistNames];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        self.similarityMatrix = [decoder decodeObjectForKey:kSimilarityMatrix];
        self.matchedArtistNames = [decoder decodeObjectForKey:kMatchedArtistNames];
    }
    return self;
}

@end

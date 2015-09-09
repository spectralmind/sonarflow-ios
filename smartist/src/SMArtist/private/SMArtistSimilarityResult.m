//
//  SMArtistSimilarityResult.m
//  SMArtist
//
//  Created by Fabian on 26.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//

#import "SMArtistSimilarityResult.h"
#import "SMArtistResult+Private.h"
#define kSimilarArtists @"sa"

@interface SMArtistSimilarityResult ()

- (void)setCombinedResults:(NSArray *)results;

@end

@implementation SMArtistSimilarityResult
{
@private
    NSArray *similarArtists;
}

@synthesize similarArtists;

+ (SMArtistSimilarityResult *)result
{
    SMArtistSimilarityResult *empty = [[SMArtistSimilarityResult alloc] init];
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
    NSMutableSet *newArtists = [NSMutableSet set];
    for (SMArtistSimilarityResult *result in results) {
		[self mergeProperties:result];
        [newArtists addObjectsFromArray:result.similarArtists];
    }
    self.similarArtists = [newArtists allObjects];
}


- (NSString *)description
{
    NSMutableString *desc = [NSMutableString stringWithString:@"SMArtistSimilarityResult with Similar Artists:\n"];
    
    for (SMSimilarArtist *sim in self.similarArtists) {
        [desc appendFormat:@"\n%@",[sim description]];
    }
    
    return desc;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:similarArtists forKey:kSimilarArtists];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        self.similarArtists = [decoder decodeObjectForKey:kSimilarArtists];
    }
    return self;
}

@end

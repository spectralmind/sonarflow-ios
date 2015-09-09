//
//  SMArtistBiosResult.m
//  SMArtist
//
//  Created by Fabian on 26.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//

#import "SMArtistBiosResult.h"
#import "SMArtistResult+Private.h"
#define kBios @"bi"

@interface SMArtistBiosResult ()

- (void)setCombinedResults:(NSArray *)results;

@end


@implementation SMArtistBiosResult
{
	@private
    NSArray *bios;
}

@synthesize bios;

+ (SMArtistBiosResult *)result
{
    SMArtistBiosResult *empty = [[SMArtistBiosResult alloc] init];
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
    NSMutableSet *newBios = [NSMutableSet set];
    for (SMArtistBiosResult *result in results) {
		[self mergeProperties:result];
		[newBios addObjectsFromArray:result.bios];
    }
    self.bios = [newBios allObjects];
}


- (NSString *)description
{
    NSMutableString *desc = [NSMutableString stringWithString:@"SMArtistBiosResult with Bios:\n"];
    
    for (SMArtistBio *bio in self.bios) {
        [desc appendFormat:@"\n%@",[bio description]];
    }
    
    return desc;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:bios forKey:kBios];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        self.bios = [decoder decodeObjectForKey:kBios];
    }
    return self;
}

@end

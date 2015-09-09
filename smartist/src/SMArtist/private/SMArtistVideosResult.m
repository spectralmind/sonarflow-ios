//
//  SMArtistVideosResult.m
//  SMArtist
//
//  Created by Fabian on 01.02.12.
//  Copyright (c) 2012 Spectralmind. All rights reserved.
//

#import "SMArtistVideosResult.h"
#import "SMArtistResult+Private.h"
#define kVideos @"vi"

@interface SMArtistVideosResult ()

- (void)setCombinedResults:(NSArray *)results;

@end

@implementation SMArtistVideosResult

{
@private
    NSArray *videos;
}

@synthesize videos;

+ (SMArtistVideosResult *)result
{
    SMArtistVideosResult *empty = [[SMArtistVideosResult alloc] init];
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
    NSMutableSet *newVideos = [NSMutableSet set];
    for (SMArtistVideosResult *result in results) {
		[self mergeProperties:result];
        [newVideos addObjectsFromArray:result.videos];
    }
    self.videos = [newVideos allObjects];
}


- (NSString *)description
{
    NSMutableString *desc = [NSMutableString stringWithString:@"SMArtistVideosResult with Videos:\n"];
    
    for (SMArtistVideo *video in self.videos) {
        [desc appendFormat:@"\n%@",[video description]];
    }
    
    return desc;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:videos forKey:kVideos];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        self.videos = [decoder decodeObjectForKey:kVideos];
    }
    return self;
}

@end

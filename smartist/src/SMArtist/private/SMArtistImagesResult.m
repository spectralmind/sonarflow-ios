//
//  SMArtistImagesResult.m
//  SMArtist
//
//  Created by Fabian on 26.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//

#import "SMArtistImagesResult.h"
#import "SMArtistResult+Private.h"
#define kImages @"im"

@interface SMArtistImagesResult ()

- (void)setCombinedResults:(NSArray *)results;

@end

@implementation SMArtistImagesResult
{
@private
    NSArray *images;
}

@synthesize images;

+ (SMArtistImagesResult *)result
{
    SMArtistImagesResult *empty = [[SMArtistImagesResult alloc] init];
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
    NSMutableSet *newImages = [NSMutableSet set];
    for (SMArtistImagesResult *result in results) {
		[self mergeProperties:result];
        [newImages addObjectsFromArray:result.images];
    }
    self.images = [newImages allObjects];
}


- (NSString *)description
{
    NSMutableString *desc = [NSMutableString stringWithString:@"SMArtistImagesResult with Images:\n"];
    
    for (SMArtistImage *image in self.images) {
        [desc appendFormat:@"\n%@",[image description]];
    }
    
    return desc;
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:images forKey:kImages];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        self.images = [decoder decodeObjectForKey:kImages];
    }
    return self;
}

@end

//
//  SMArtistGenresResult.m
//  SMArtist
//
//  Created by Arvid Staub on 9.8.2012.
//
//

#import "SMArtistGenresResult.h"
#import "SMArtistResult+Private.h"

#define kTags	@"tg"

@implementation SMArtistGenresResult

@synthesize genres;

+ (SMArtistGenresResult *)result {
	return [[self alloc] init];
}

- (id)initWithResults:(NSArray *)results {
	self = [super init];
	if(self == nil) {
		return nil;
	}

	NSMutableArray *allGenres = [NSMutableArray array];
	for(SMArtistGenresResult *result in results) {
		[self mergeProperties:result];
		[allGenres addObjectsFromArray:result.genres];
	}
	
	self.genres = allGenres;
	
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Discovered Genre: %@>", self.genres];
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:self.genres forKey:kTags];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        self.genres = [decoder decodeObjectForKey:kTags];
    }
    return self;
}


@end

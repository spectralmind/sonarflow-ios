//
//  SMArtistBios.m
//  SMArtist
//
//  Created by Fabian on 29.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//

#import "SMArtistBio.h"
#define kFulltext @"ft"
#define kPreviewText @"pt"
#define kSourceName @"sn"
#define kUrl @"url"

@implementation SMArtistBio
{
@private
    NSString *fulltext;
    NSString *previewText;
    NSString *sourceName;
    NSString *url;
}

@synthesize fulltext, previewText, sourceName, url;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (SMArtistBio *)artistBioWithUrl:(NSString *)bioUrl withSourceName:(NSString *)sourceName withPreviewText:(NSString *)previewText withFullText:(NSString *)fullText
{
    SMArtistBio *artistBio = [[SMArtistBio alloc] init];
    artistBio.url = bioUrl;
    artistBio.sourceName = sourceName;
    artistBio.previewText = previewText;
    artistBio.fulltext = fullText;
    return artistBio;
}

- (BOOL)isEqual:(id)object {
	if([object isKindOfClass:[self class]] == NO) {
		return NO;
	}
	
	return [self isEqualToBio:object];
}

- (NSUInteger)hash {
	return [self.url hash];
}

- (BOOL)isEqualToBio:(SMArtistBio *)other {
	return [self.url isEqual:other.url];
}

- (BOOL)isSame:(SMArtistBio *)aBio;
{
	return [self isEqualToBio:aBio];
}

- (BOOL)isValid
{
    if (self.url && ((self.fulltext && [self.fulltext length] > 100) || (self.previewText && [self.previewText length] > 10))) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"SMArtistBio:\n\tBio Source Name: %@\n\tUrl: %@ \n\tSummary: %@\n\tFull Text: %@", self.sourceName, self.url, self.previewText, self.fulltext];
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:fulltext forKey:kFulltext];
    [encoder encodeObject:previewText forKey:kPreviewText];
    [encoder encodeObject:sourceName forKey:kSourceName];
    [encoder encodeObject:url forKey:kUrl];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (self) {
        self.fulltext = [decoder decodeObjectForKey:kFulltext];
        self.previewText = [decoder decodeObjectForKey:kPreviewText];
        self.sourceName = [decoder decodeObjectForKey:kSourceName];
        self.url = [decoder decodeObjectForKey:kUrl];
    }
    return self;
}

@end

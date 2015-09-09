//
//  SMArtistVideo.m
//  SMArtist
//
//  Created by Fabian on 01.02.12.
//  Copyright (c) 2012 Spectralmind. All rights reserved.
//

#import "SMArtistVideo.h"
#define kVideoUrl @"videoUrl"
#define kVideoTitle @"title"

@implementation SMArtistVideo
{
@private
    NSString *videoUrl;
	NSString *title;
}

@synthesize videoUrl;
@synthesize title;




+ (SMArtistVideo *)artistVideoWithUrl:(NSString *)videoUrl andTitle:(NSString *)videoTitle {
    SMArtistVideo *artistVideo = [[SMArtistVideo alloc] init];
    artistVideo.videoUrl = videoUrl;
	artistVideo.title = videoTitle;
	
    return artistVideo;
}

- (BOOL)isEqual:(id)object {
	if([object isKindOfClass:[self class]] == NO) {
		return NO;
	}
	
	return [self isEqualToArtistVideo:object];
}

- (NSUInteger)hash {
	return [self.videoUrl hash];
}

- (BOOL)isEqualToArtistVideo:(SMArtistVideo *)other {
	return [self.videoUrl isEqual:other.videoUrl];
}

- (BOOL)isSame:(SMArtistVideo *)aVideo
{
	return [self isEqualToArtistVideo:aVideo];
}

- (BOOL)isValid
{
    if (self.videoUrl) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"SMArtistVideo:\n\tVideo Title: %@\n\tVideo Url: %@", self.title, self.videoUrl];
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:videoUrl forKey:kVideoUrl];
    [encoder encodeObject:title forKey:kVideoTitle];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (self) {
        self.videoUrl = [decoder decodeObjectForKey:kVideoUrl];
        self.title = [decoder decodeObjectForKey:kVideoTitle];
    }
    return self;
}

@end

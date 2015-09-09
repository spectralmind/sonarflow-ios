//
//  SMSimilarArtist.m
//  SMArtist
//
//  Created by Fabian on 29.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//

#import "SMArtistImage.h"
#import <CoreGraphics/CGBase.h>
#import <CoreGraphics/CGGeometry.h>
#import <UIKit/UIGeometry.h>

#define kImageUrl @"imageUrl"
#define kImageSize @"imageSize"

@implementation SMArtistImage
{
@private
    NSString *imageUrl;
    NSValue *imageSize;
}

@synthesize imageUrl, imageSize;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (SMArtistImage *)artistImageWithUrl:(NSString *)imageUrl withSize:(NSValue *)imageSize
{
    SMArtistImage *artistImage = [[SMArtistImage alloc] init];
    artistImage.imageUrl = imageUrl;
    artistImage.imageSize = imageSize;
    return artistImage;
}

- (BOOL)isEqual:(id)object {
	if([object isKindOfClass:[self class]] == NO) {
		return NO;
	}
	
	return [self isEqualToArtistImage:object];
}

- (NSUInteger)hash {
	return [self.imageUrl hash] ^ [self.imageSize hash];
}

- (BOOL)isEqualToArtistImage:(SMArtistImage *)other {
	return [self.imageUrl isEqual:other.imageUrl] &&
		((self.imageSize && other.imageSize) ?
			CGSizeEqualToSize([self.imageSize CGSizeValue], [other.imageSize CGSizeValue]) :
			self.imageSize == other.imageSize);
}

- (BOOL)isSame:(SMArtistImage *)anImage {
	return [self isEqualToArtistImage:anImage];
}

- (BOOL)isValid
{
    if (self.imageUrl /* && self.imageSize */) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"SMArtistImage:\n\tImage Url: %@\n\tImage Size: %0.0fx%0.0f", self.imageUrl, [self.imageSize CGSizeValue].width, [self.imageSize CGSizeValue].height];
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:imageUrl forKey:kImageUrl];
    [encoder encodeObject:imageSize forKey:kImageSize];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (self) {
        self.imageUrl = [decoder decodeObjectForKey:kImageUrl];
        self.imageSize = [decoder decodeObjectForKey:kImageSize]; 
    }
    return self;
}

@end

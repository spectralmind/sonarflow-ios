//
//  SMSimilarArtist.m
//  SMArtist
//
//  Created by Fabian on 29.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//

#import "SMSimilarArtist.h"
#define kArtistName @"artistName"
#define kMatchValue @"matchValue"

@implementation SMSimilarArtist
{
@private
    NSString *artistName;
    CGFloat matchValue;
}

@synthesize artistName, matchValue;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (SMSimilarArtist *)similarArtistWithName:(NSString *)artistName withMatchValue:(CGFloat)matchValue
{
    SMSimilarArtist *similarArtist = [[SMSimilarArtist alloc] init];
    similarArtist.artistName = artistName;
    similarArtist.matchValue = matchValue;
    return similarArtist;
}

- (BOOL)isEqual:(id)object {
	if([object isKindOfClass:[self class]] == NO) {
		return NO;
	}
	
	return [self isEqualToSimilarArtist:object];
}

- (NSUInteger)hash {
	return [self.artistName hash];
}

- (BOOL)isEqualToSimilarArtist:(SMSimilarArtist *)other {
	return [self.artistName isEqual:other.artistName];
}

- (BOOL)isSame:(SMSimilarArtist *)aSimilarArtist
{
	return [self isEqualToSimilarArtist:aSimilarArtist];
}

- (BOOL)isValid
{
    if (self.artistName) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"SMSimilarArtist:\n\tArtist Name: %@\n\tMatch Value: %0.3f", self.artistName, matchValue];
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:artistName forKey:kArtistName];
    [encoder encodeFloat:matchValue forKey:kMatchValue];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (self) {
        self.artistName = [decoder decodeObjectForKey:kArtistName];
        self.matchValue = [decoder decodeFloatForKey:kMatchValue];
    }
    return self;
}

@end

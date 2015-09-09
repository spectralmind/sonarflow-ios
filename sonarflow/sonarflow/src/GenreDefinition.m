//
//  GenreDefinition.m
//  sonarflow
//
//  Created by Raphael Charwot on 07.09.11.
//  Copyright (c) 2011 Charwot. All rights reserved.
//

#import "GenreDefinition.h"

@implementation GenreDefinition

- (id)initWithName:(NSString *)theName origin:(CGPoint)theOrigin color:(UIColor *)theColor subgenres:(NSArray *)theSubgenres {
    self = [super init];
    if (self) {
		name = theName;
		origin = theOrigin;
		color = theColor;
		subgenres = theSubgenres;
    }
    return self;
}


@synthesize name;
@synthesize origin;
@synthesize color;
@synthesize subgenres;

- (BOOL)containsGenreName:(NSString *)genreName {
	for(NSString *subGenre in self.subgenres) {
		if([subGenre length] == 0) {
			return YES;
		}

		NSRange result = [genreName rangeOfString:subGenre options:NSCaseInsensitiveSearch];
		if(result.location != NSNotFound) {
			return YES;
		}
	}

	return NO;
}

@end

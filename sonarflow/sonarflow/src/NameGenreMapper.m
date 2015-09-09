//
//  NameGenreMapper.m
//  Sonarflow
//
//  Created by Raphael Charwot on 18.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import "NameGenreMapper.h"
#import "GenreDefinition.h"

static NSString *kCatchAllName = @"";

@implementation NameGenreMapper {
	NSArray *genreDefinitions;
	NSMutableDictionary *nameGenreMap;
	NSMutableDictionary *lookedUpGenresByMediaId;
}


- (id)initWithGenreDefinitions:(NSArray *)theGenreDefinitions; {
	if(self = [super init])	{
		genreDefinitions = theGenreDefinitions;
		nameGenreMap = [[NSMutableDictionary alloc] init];
		lookedUpGenresByMediaId = [NSMutableDictionary dictionary];
		[self mapCatchAllGenreDefinition];
	}
	return self;
}

- (void)mapCatchAllGenreDefinition {
	for(GenreDefinition *genreDefinition in genreDefinitions) {
		if([genreDefinition containsGenreName:@""]) {
			[nameGenreMap setObject:genreDefinition forKey:kCatchAllName];
			return;
		}
	}
	
	NSAssert(0, @"Couldn't find catch-all genre");
}


- (GenreDefinition *)genreDefinitionForName:(NSString *)genreName {
	if(genreName == nil) {
		genreName = kCatchAllName;
	}
	
	GenreDefinition *genre = [nameGenreMap objectForKey:genreName];
	if(genre == nil) {
		genre = [self findGenreDefinitionAndUpdateMap:genreName];
	}
	
	return genre;
}

- (GenreDefinition *)findGenreDefinitionAndUpdateMap:(NSString *)genreName {
	for(GenreDefinition *genreDefinition in genreDefinitions) {
		if([genreDefinition containsGenreName:genreName]) {
			[nameGenreMap setObject:genreDefinition forKey:genreName];
			return genreDefinition;
		}
	}

	NSAssert(0, @"Genre not found");
	return nil;
}

- (GenreDefinition *)catchAllGenreDefinition {
	return [self genreDefinitionForName:kCatchAllName];
}

- (NSString *)mappedNameForGenreName:(NSString *)name {
	return [self genreDefinitionForName:name].name;
}

- (NSString *)mappedNameForGenreName:(NSString *)name usingArtistName:(NSString *)artistName {
	GenreDefinition *definition = [self genreDefinitionForName:name];
	if(definition != [self catchAllGenreDefinition]) {
		return definition.name;
	}
	
	GenreDefinition *lookupGenreDefiniton = [lookedUpGenresByMediaId objectForKey:artistName];
	if(lookupGenreDefiniton != nil) {
		return lookupGenreDefiniton.name;
	}
	
	return definition.name;
}


- (void)registerGenreLookupResult:(GenreDefinition *)genre forArtistName:(NSString *)artistName {
	dispatch_async(dispatch_get_main_queue(), ^{
		[lookedUpGenresByMediaId setObject:genre forKey:artistName];
	});
}

@end

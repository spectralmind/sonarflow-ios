//
//  NameGenreMapper.h
//  Sonarflow
//
//  Created by Raphael Charwot on 18.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GenreDefinition;

@interface NameGenreMapper : NSObject

- (id)initWithGenreDefinitions:(NSArray *)theGenreDefinitions;

- (GenreDefinition *)genreDefinitionForName:(NSString *)name;
- (GenreDefinition *)catchAllGenreDefinition;
- (NSString *)mappedNameForGenreName:(NSString *)name;

- (void)registerGenreLookupResult:(GenreDefinition *)genre forArtistName:(NSString *)artistName;
- (NSString *)mappedNameForGenreName:(NSString *)name usingArtistName:(NSString *)artistName;

@end

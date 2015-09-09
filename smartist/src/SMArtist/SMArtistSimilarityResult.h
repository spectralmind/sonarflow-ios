//
//  SMArtistSimilarityResult.h
//  SMArtist
//
//  Created by Fabian on 26.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//
// Specific return object containing Artist Similarities
//

#import "SMArtistResult.h"
#import "SMSimilarArtist.h"

/*!
 @class SMArtistSimilarityResult
 
 @abstract An SMArtistSimilarityResult object holds information about simililar artists to one artist.
 
 @discussion  
 */
@interface SMArtistSimilarityResult : SMArtistResult

/*!
 @method result
 @abstract Allocates and initializes an empty SMArtistSimilarityResult. 
 @result A newly-created and autoreleased SMArtistSimilarityResult instance. 
 */
+ (SMArtistSimilarityResult *)result;

- (id)initWithResults:(NSArray *)results;

/*!
 @property similarArtists
 @abstract An NSArray containing SMSimilarArtist objects, each representing one similar artist.
 */
@property (nonatomic, strong) NSArray *similarArtists;

@end

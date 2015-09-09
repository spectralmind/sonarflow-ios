//
//  SMArtistSimilarityMatrixResult.h
//  SMArtist
//
//  Created by Fabian on 09.12.11.
//  Copyright (c) 2011 Spectralmind. All rights reserved.
//
// Specific return object containing an Artist Similarity Matrix
//

#import "SMArtistResult.h"
#import "SMSimilarArtist.h"

/*!
 @class SMArtistSimilarityMatrixResult
 
 @abstract An SMArtistSimilarityMatrixResult object holds a matrix with similarities between a set of artists.
 
 @discussion  
 */
@interface SMArtistSimilarityMatrixResult : SMArtistResult

/*!
 @method result
 @abstract Allocates and initializes an empty SMArtistSimilarityMatrixResult. 
 @result A newly-created and autoreleased SMArtistSimilarityMatrixResult instance. 
 */
+ (SMArtistSimilarityMatrixResult *)result;

- (id)initWithResults:(NSArray *)results;

/*!
 @property similarityMatrix
 @abstract An NSDictionary containing (recognized) artist names as NSStrings as keys and NSDictionary's as objects which in turn contain (recognized) artist names as NSStrings as keys and as NSNumber's with a float representation of the similarities in range [0,1] as objects.
 @discussion A structure looks like the following:
     { ArtistName1 : {
         ArtistName2 : 0.5,
         ArtistName3 : 0.3},
	   ArtistName2 : {
         ArtistName1 : 0.7,
         ArtistName3 : 0.2},
       ArtistName3 : {
         ArtistName1 : 0.1,
         ArtistName2 : 0.4}
     }
 */
@property (nonatomic, strong) NSDictionary *similarityMatrix;

/*!
 @property matchedArtistNames
 @abstract An NSDictionary containing requested artist names as NSStrings as keys and matched artist names as NSStrings as objects.
 */
@property (nonatomic, strong) NSDictionary *matchedArtistNames;

@end

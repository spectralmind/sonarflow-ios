//
//  SMArtistImagesResult.h
//  SMArtist
//
//  Created by Fabian on 26.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//
// Specific return object containing Artist Image urls
//

#import "SMArtistResult.h"
#import "SMArtistImage.h"

/*!
 @class SMArtistImagesResult
 
 @abstract An SMArtistImagesResult object holds images of one artist.
 
 @discussion 
 */
@interface SMArtistImagesResult : SMArtistResult

/*!
 @method result
 @abstract Allocates and initializes an empty SMArtistImagesResult. 
 @result A newly-created and autoreleased SMArtistImagesResult instance. 
 */
+ (SMArtistImagesResult *)result;

- (id)initWithResults:(NSArray *)results;

/*!
 @property images
 @abstract An NSArray containing SMArtistImage objects, each representing one artist image.
 */
@property (nonatomic, strong) NSArray *images;

@end

//
//  SMArtistBiosResult.h
//  SMArtist
//
//  Created by Fabian on 26.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//
// Specific return object containing Artist Biographies
//

#import "SMArtistResult.h"
#import "SMArtistBio.h"

/*!
 @class SMArtistBiosResult
 
 @abstract An SMArtistBiosResult object holds information about a row of biographies of one artist.
 
 @discussion 
 */
@interface SMArtistBiosResult : SMArtistResult

/*!
 @method result
 @abstract Allocates and initializes an empty SMArtistBiosResult. 
 @result A newly-created and autoreleased SMArtistBiosResult instance. 
 */
+ (SMArtistBiosResult *)result;

- (id)initWithResults:(NSArray *)results;


/*!
 @property bios
 @abstract An NSArray containing SMArtistBio objects, each representing one biography.
 */
@property (nonatomic, strong) NSArray *bios;

@end

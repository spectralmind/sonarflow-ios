//
//  SMArtistVideosResult.h
//  SMArtist
//
//  Created by Fabian on 01.02.12.
//  Copyright (c) 2012 Spectralmind. All rights reserved.
//

#import "SMArtistResult.h"
#import "SMArtistVideo.h"

/*!
 @class SMArtistVideosResult
 
 @abstract An SMArtistVideosResult object holds videos of one artist.
 
 @discussion 
 */
@interface SMArtistVideosResult : SMArtistResult

/*!
 @method result
 @abstract Allocates and initializes an empty SMArtistVideosResult. 
 @result A newly-created and autoreleased SMArtistVideosResult instance. 
 */
+ (SMArtistVideosResult *)result;

- (id)initWithResults:(NSArray *)results;

/*!
 @property videos
 @abstract An NSArray containing SMArtistVideo objects, each representing one artist video.
 */
@property (nonatomic, strong) NSArray *videos;

@end

//
//  SMArtistVideo.h
//  SMArtist
//
//  Created by Fabian on 01.02.12.
//  Copyright (c) 2012 Spectralmind. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @class SMArtistVideo
 
 @abstract An SMArtistVideo object represents one artist video.
 
 @discussion 
 */
@interface SMArtistVideo : NSObject

/*!
 @method artistVideoWithUrl:
 @abstract Allocates and initializes a SMArtistVideo. 
 @param videoUrl The embedding URL of the video.
 @param videoTitle The title of the video.
 @result A newly-created and autoreleased SMArtistVideo instance. 
 */
+ (SMArtistVideo *)artistVideoWithUrl:(NSString *)videoUrl andTitle:(NSString *)videoTitle;

/*!
 @property videoUrl
 @abstract The embedding URL of the video.
 */
@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) NSString *title;


- (BOOL)isEqualToArtistVideo:(SMArtistVideo *)other;

/*!
 @method isSame
 @abstract Compares this instance to the given one.
	This method compares the videoUrl.
 @result A BOOL expressing whether the two instances are the same.
 */
- (BOOL)isSame:(SMArtistVideo *)aVideo;

/*!
 @method isValid
 @abstract Checks whether all necessary fields are set.
	This method checks the the videoUrl.
 @result A BOOL expressing whether this instance is valid.
 */
- (BOOL)isValid;

@end

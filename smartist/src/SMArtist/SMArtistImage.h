//
//  SMSimilarArtist.h
//  SMArtist
//
//  Created by Fabian on 29.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @class SMArtistImage
 
 @abstract An SMArtistImage object represents one artist image.
 
 @discussion 
 */
@interface SMArtistImage : NSObject <NSCoding>

/*!
 @method artistImageWithUrl:withSize:
 @abstract Allocates and initializes a SMArtistImage. 
 @param imageUrl The URL where this image is located.
 @param imageSize The size of this image.
 @result A newly-created and autoreleased SMArtistImage instance. 
 */
+ (SMArtistImage *)artistImageWithUrl:(NSString *)imageUrl withSize:(NSValue *)imageSize;


/*!
 @property imageUrl
 @abstract The URL where this image is located.
 */
@property (nonatomic, strong) NSString *imageUrl;

/*!
 @property imageSize
 @abstract The size of this image.
 @discussion Contains a CGSize.
    nil if size unknown.
 */
@property (nonatomic, strong) NSValue *imageSize;

- (BOOL)isEqualToArtistImage:(SMArtistImage *)other;

/*!
 @method isSame
 @abstract Compares this instance to the given one.
    This method compares the imageUrl and the imageSize.
 @result A BOOL expressing whether the two instances are the same.
 */
- (BOOL)isSame:(SMArtistImage *)anImage;

/*!
 @method isValid
 @abstract Checks whether all necessary fields are set.
    This method checks the the imageUrl and ignores imageSize as it can be nil.
 @result A BOOL expressing whether this instance is valid.
 */
- (BOOL)isValid;

@end

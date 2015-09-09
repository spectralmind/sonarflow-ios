//
//  SMArtistBios.h
//  SMArtist
//
//  Created by Fabian on 29.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @class SMArtistBio
 
 @abstract An SMArtistBio object represents one artist biography.
 
 @discussion If only a preview of the biography is available, fulltext is nil.
 */
@interface SMArtistBio : NSObject <NSCoding>

/*!
 @method artistBioWithUrl:artistBioWithUrl:withPreviewText:withFullText:
 @abstract Allocates and initializes a SMArtistBio.
 @param bioUrl The URL with the full biography.
 @param sourceName A String representing the source (like "wikipedia").
 @param previewText A short preview of the full biography text.
 @param fullText The full text of the biography.
 @result A newly-created and autoreleased SMArtistBio instance. 
 */
+ (SMArtistBio *)artistBioWithUrl:(NSString *)bioUrl withSourceName:(NSString *)sourceName withPreviewText:(NSString *)previewText withFullText:(NSString *)fullText;

// note that Echonest crops most biographies


/*!
 @property fulltext
 @abstract The full text of the biography.
 @discussion Might be nil if full text only available under url.
 */
@property (nonatomic, strong) NSString *fulltext;

/*!
 @property previewText
 @abstract A short preview of the full biography text.
 */
@property (nonatomic, strong) NSString *previewText;

/*!
 @property sourceName
 @abstract A String representing the source (like "wikipedia").
 */
@property (nonatomic, strong) NSString *sourceName;

/*!
 @property url
 @abstract The URL with the full biography.
 */
@property (nonatomic, strong) NSString *url;


- (BOOL)isEqualToBio:(SMArtistBio *)aBio;

/*!
 @method isSame
 @abstract Compares this instance to the given one.
    This method just compares the url and ignores the other properties.
 @result A BOOL expressing whether the two instances are the same.
 */
- (BOOL)isSame:(SMArtistBio *)aBio;

/*!
 @method isValid
 @abstract Checks whether all necessary fields are set.
 This method just checks the url and ignores the other properties.
 @result A BOOL expressing whether this instance is valid.
 */
- (BOOL)isValid;

@end

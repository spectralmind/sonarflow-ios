//
//  SMSimilarArtist.h
//  SMArtist
//
//  Created by Fabian on 29.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGBase.h>

/*!
 @class SMSimilarArtist
 
 @abstract An SMSimilarArtist object represents one similar artist.
 
 @discussion 
 */
@interface SMSimilarArtist : NSObject <NSCoding>

/*!
 @method similarArtistWithName:withMatchValue:
 @abstract Allocates and initializes a SMSimilarArtist. 
 @param artistName The name of this similar artist.
 @param matchValue The match value defining how good this artist matches the original one. In range [0,1].
 @result A newly-created and autoreleased SMSimilarArtist instance. 
 */
+ (SMSimilarArtist *)similarArtistWithName:(NSString *)artistName withMatchValue:(CGFloat)matchValue;


/*!
 @property artistName
 @abstract The name of this similar artist.
 */
@property (nonatomic, strong) NSString *artistName;

// match value of this artist in range [0,1]

/*!
 @property matchValue
 @abstract The match value defining how good this artist matches the original one. In range [0,1].
 */
@property CGFloat matchValue;


- (BOOL)isEqualToSimilarArtist:(SMSimilarArtist *)other;

/*!
 @method isSame
 @abstract Compares this instance to the given one.
    This method just compares the artistName and ignores the other properties.
 @result A BOOL expressing whether the two instances are the same.
 */
- (BOOL)isSame:(SMSimilarArtist *)aSimilarArtist;

/*!
 @method isValid
 @abstract Checks whether all necessary fields are set.
 This method just checks the artistName and ignores the other properties.
 @result A BOOL expressing whether this instance is valid.
 */
- (BOOL)isValid;

@end

//
//  SMArtistResult.h
//  SMArtist
//
//  Created by Fabian on 22.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//
// ABSTRACT Result Class
//

#import <Foundation/Foundation.h>

#import "SMArtistConfiguration.h"

/*!
 @class SMArtistResult
 
 @abstract SMArtistResult is an ABSTRACT class which represents some kind of result for a SMArtist query.
 
 @discussion The actual result properti/es are only contained in derived classes
 */
@interface SMArtistResult : NSObject

/*! 
 @property clientId
 @abstract Any object a client provided when doing the corresponding request.
 */
@property (nonatomic, strong) id clientId;


/*! 
 @property recognizedArtistName
 @abstract The artist name that was matched against at the web service(s).
 @discussion Requested artist name if no matching artists were found at the webservices.
             nil for results that contain info about more than one artist.
 */
@property (nonatomic, strong) NSString *recognizedArtistName;


/*! 
 @property error
 @abstract An NSError object representing happened errors while doing the web request.
 @discussion This can hold an error, even when the specific result property in subclass is a useable result.
    That case happens when at least one, but not all, of the queried web services returns a faulty result.
 */
@property (nonatomic, strong) NSError *error;



#pragma mark - DEBUG stuff

/*! 
 @property info
 @abstract DEBUG - A NSDictionary which contains additional infos about this result, like timing information of the web request
 */
@property (nonatomic, strong) NSDictionary *info;


@end

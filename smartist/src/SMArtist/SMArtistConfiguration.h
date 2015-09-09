//
//  SMArtistConfiguration.h
//  SMArtist
//
//  Created by Fabian on 08.12.11.
//  Copyright (c) 2011 Spectralmind. All rights reserved.
//
// Configuration Object for customizing the behavior of SMArtist
//

#import <Foundation/Foundation.h>


/*!
 @enum SMArtistWebServices
 @abstract Various types of web services.
 @discussion 
 */
enum {
	SMArtistWebServicesNone     = 0,
	SMArtistWebServicesLastfm   = 1 << 0,
	SMArtistWebServicesEchonest = 1 << 1,
	SMArtistWebServicesYoutube = 1 << 2
};
typedef NSUInteger SMArtistWebServices;


/*!
 @class SMArtistConfiguration
 
 @abstract A SMArtistConfiguration object is used to configure various aspects of SMArtist.
 
 @discussion SMArtistConfiguration needs to be initialized at least with an echonestKey and a lastfmKey.
 */
@interface SMArtistConfiguration : NSObject


/*! 
 @method defaultConfiguration
 @abstract Allocates and initializes a SMArtistConfiguration with default configuration values.
           echonestKey and a lastfmKey are NOT yet set.
 @result A newly-created and autoreleased SMArtistConfiguration instance. 
 */
+ (SMArtistConfiguration *)defaultConfiguration;



/*! 
 @property echonestKey
 @abstract API Key for Echonest.
 @discussion Needs to be set before SMArtist requests to Echonest can be done.
 */
@property (nonatomic, strong) NSString *echonestKey;

/*! 
 @property echonestUrl
 @abstract Endpoint Url of Echonest. Must include trailing slash.
 @discussion Defaults to @"http://developer.echonest.com/api/v4/".
 */
@property (nonatomic, strong) NSString *echonestUrl;

/*! 
 @property echonestTimeout
 @abstract Url request timeout in seconds for single requests to Echonest.
 @discussion Defaults to 60.
 */
@property (nonatomic, assign) NSUInteger echonestTimeout;

/*! 
 @property echonestTimeBetweenRequests
 @abstract Waiting time between single requests to Echonest.
 @discussion Defaults to 0.5.
 */
@property (nonatomic, assign) NSTimeInterval echonestTimeBetweenRequests;


/*! 
 @property lastfmKey
 @abstract API Key for Last.fm.
 @discussion Needs to be set before SMArtist requests to Last.fm can be done.
 */
@property (nonatomic, strong) NSString *lastfmKey;

/*! 
 @property lastfmUrl
 @abstract Endpoint Url of Last.fm. Must include trailing slash.
 @discussion Defaults to @"http://ws.audioscrobbler.com/2.0/".
 */
@property (nonatomic, strong) NSString *lastfmUrl;

/*! 
 @property lastfmTimeout
 @abstract Url request timeout in seconds for single requests to Last.fm.
 @discussion Defaults to 60.
 */
@property (nonatomic, assign) NSUInteger lastfmTimeout;

/*! 
 @property lastfmTimeBetweenRequests
 @abstract Waiting time between single requests to Last.fm.
 @discussion Defaults to 0.2.
 */
@property (nonatomic, assign) NSTimeInterval lastfmTimeBetweenRequests;


/*! 
 @property youtubeUrl
 @abstract Endpoint Url of Youtube. Must include trailing slash.
 @discussion Defaults to @"https://gdata.youtube.com/feeds/api/".
 */
@property (nonatomic, strong) NSString *youtubeUrl;

/*! 
 @property youtubeTimeout
 @abstract Url request timeout in seconds for single requests to Youtube.
 @discussion Defaults to 60.
 */
@property (nonatomic, assign) NSUInteger youtubeTimeout;

/*! 
 @property youtubeTimeBetweenRequests
 @abstract Waiting time between single requests to Youtube.
 @discussion Defaults to 0.0.
 */
@property (nonatomic, assign) NSTimeInterval youtubeTimeBetweenRequests;


/*! 
 @property cacheExpirationTime
 @abstract Time interval that results should be cached for.
 @discussion Defaults to 1 week.
 */
@property (nonatomic, assign) NSTimeInterval cacheExpirationTime;


/*! 
 @property servicesMaskAllRequests
 @abstract Selections of webservices that should be used for all requests.
 @discussion Defaults to SMArtistWebServicesLastfm | SMArtistWebServicesEchonest | SMArtistWebServicesYoutube.
	Setting this overwrites all other servicesMasks.
	Don't read this property, as it will return garbage when different services are configured for different requests.
 */
@property (nonatomic, assign) SMArtistWebServices servicesMaskAllRequests;

/*! 
 @property servicesMaskBiosRequests
 @abstract Selections of webservices that should be used for artist bios requests.
 @discussion Defaults to servicesMaskAllRequests.
 */
@property (nonatomic, assign) SMArtistWebServices servicesMaskBiosRequests;

/*! 
 @property servicesMaskImagesRequests
 @abstract Selections of webservices that should be used for artist images requests.
 @discussion Defaults to servicesMaskAllRequests.
 */
@property (nonatomic, assign) SMArtistWebServices servicesMaskImagesRequests;

/*! 
 @property servicesMaskSimilarityRequests
 @abstract Selections of webservices that should be used for artist similarity requests.
 @discussion Defaults to servicesMaskAllRequests.
 */
@property (nonatomic, assign) SMArtistWebServices servicesMaskSimilarityRequests;

/*! 
 @property servicesMaskVideosRequests
 @abstract Selections of webservices that should be used for artist videos requests.
 @discussion Defaults to servicesMaskAllRequests.
 */
@property (nonatomic, assign) SMArtistWebServices servicesMaskVideosRequests;

@property (nonatomic, assign) SMArtistWebServices servicesMaskGenresRequests;


@end

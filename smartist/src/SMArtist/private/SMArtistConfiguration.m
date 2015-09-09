//
//  SMArtistConfiguration.m
//  SMArtist
//
//  Created by Fabian on 08.12.11.
//  Copyright (c) 2011 Spectralmind. All rights reserved.
//

#import "SMArtistConfiguration.h"

@implementation SMArtistConfiguration
{
@private
	NSString *echonestKey;
	NSString *echonestUrl;
	NSUInteger echonestTimeout;
	NSTimeInterval echonestTimeBetweenRequests;
	
	NSString *lastfmKey;
	NSString *lastfmUrl;
	NSUInteger lastfmTimeout;
	NSTimeInterval lastfmTimeBetweenRequests;

	NSString *youtubeUrl;
	NSUInteger youtubeTimeout;
	NSTimeInterval youtubeTimeBetweenRequests;

	NSTimeInterval cacheExpirationTime;
	
	SMArtistWebServices servicesMaskBiosRequests;
	SMArtistWebServices servicesMaskImagesRequests;
	SMArtistWebServices servicesMaskSimilarityRequests;
	SMArtistWebServices servicesMaskVideosRequests;
}

@synthesize echonestKey;
@synthesize echonestUrl;
@synthesize echonestTimeout;
@synthesize echonestTimeBetweenRequests;

@synthesize lastfmKey;
@synthesize lastfmUrl;
@synthesize lastfmTimeout;
@synthesize lastfmTimeBetweenRequests;

@synthesize youtubeUrl;
@synthesize youtubeTimeout;
@synthesize youtubeTimeBetweenRequests;

@synthesize cacheExpirationTime;

@synthesize servicesMaskBiosRequests;
@synthesize servicesMaskImagesRequests;
@synthesize servicesMaskSimilarityRequests;
@synthesize servicesMaskVideosRequests;
@synthesize servicesMaskGenresRequests;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
		self.lastfmUrl = @"http://ws.audioscrobbler.com/2.0/";
		self.lastfmTimeout = 60;
		self.lastfmTimeBetweenRequests = 0.2;
	
		self.echonestUrl = @"http://developer.echonest.com/api/v4/";
		self.echonestTimeout = 60;
		self.echonestTimeBetweenRequests = 0.5;
		
		self.youtubeUrl = @"https://gdata.youtube.com/feeds/api/";
		self.youtubeTimeout = 60;
		self.youtubeTimeBetweenRequests = 0.0;
		
		self.cacheExpirationTime = 60 * 60 * 24 * 7;
		
		self.servicesMaskAllRequests = SMArtistWebServicesLastfm | SMArtistWebServicesEchonest | SMArtistWebServicesYoutube;
	}
    
    return self;
}


+ (SMArtistConfiguration *)defaultConfiguration
{
    SMArtistConfiguration *configuration = [[SMArtistConfiguration alloc] init];
    return configuration;
}

- (void)setServicesMaskAllRequests:(SMArtistWebServices)servicesMaskAllRequests
{
	self.servicesMaskBiosRequests = servicesMaskAllRequests;
	self.servicesMaskImagesRequests = servicesMaskAllRequests;
	self.servicesMaskSimilarityRequests = servicesMaskAllRequests;
	self.servicesMaskVideosRequests = servicesMaskAllRequests;
	self.servicesMaskGenresRequests = servicesMaskAllRequests;
}

- (SMArtistWebServices)servicesMaskAllRequests
{
	return self.servicesMaskBiosRequests |
		self.servicesMaskImagesRequests |
		self.servicesMaskSimilarityRequests |
		self.servicesMaskVideosRequests |
		self.servicesMaskGenresRequests;
}

@end

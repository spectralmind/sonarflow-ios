//
//  SMRootFactory.m
//  SMArtist
//
//  Created by Fabian on 06.09.11.
//  Copyright (c) 2011 Spectralmind. All rights reserved.
//

#import "SMRootFactory.h"
#import "SMNetworkAwareResultCache.h"
#import "SMRateLimitedQueue.h"


@implementation SMRootFactory {
	@private
	SMArtistConfiguration *configuration;
	SMArtistRequestFactory *requestFactory;
	SMRequestableFactory *requestableFactory;
    SMWebInfoFactory *webinfoFactory;
    SMUrlConnectionFactory *urlconnectionFactory;
	SMResultCache *cache;
}

@synthesize configuration;
@synthesize cache;

- (id)init {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)initWithConfiguration:(SMArtistConfiguration *)theConfiguration {
	self = [super init];
    if (self) {
		configuration = theConfiguration;
		cache = [[SMNetworkAwareResultCache alloc] initWithMaximumAge:configuration.cacheExpirationTime];
    }
    
    return self;
}



#pragma mark - Factories

- (SMArtistRequestFactory *)requestFactory {
	@synchronized(self) {
		if(requestFactory == nil) {
			requestFactory = [[SMArtistRequestFactory alloc] init];
			requestFactory.rootFactory = self;
		}
	}
	
	return requestFactory;
}

- (SMRequestableFactory *)requestableFactory {
	@synchronized(self) {
		if(requestableFactory == nil) {
			requestableFactory = [[SMRequestableFactory alloc] initWithCache:cache];
			requestableFactory.rootFactory = self;
		}
	}
	
	return requestableFactory;
}

- (SMWebInfoFactory *)webinfoFactory {
	@synchronized(self) {
		if(webinfoFactory == nil) {
			webinfoFactory = [[SMWebInfoFactory alloc] init];
			webinfoFactory.rootFactory = self;
		}
	}
	
	return webinfoFactory;
}

- (SMUrlConnectionFactory *)urlconnectionFactory {
	@synchronized(self) {
		if(urlconnectionFactory == nil) {
			urlconnectionFactory = [[SMUrlConnectionFactory alloc] init];
			urlconnectionFactory.rootFactory = self;
		}
	}
	
	return urlconnectionFactory;
}


- (SMRateLimitedQueue *)getQueueForYoutube {
	static SMRateLimitedQueue *youtubeQueue = nil;
	@synchronized(SMRootFactory.class) {
		if(youtubeQueue == nil) {
			NSTimeInterval ratelimit = [configuration youtubeTimeBetweenRequests];
			youtubeQueue = [[SMRateLimitedQueue alloc] initWithMinimumInterval:ratelimit];
		}
	}
	
	return youtubeQueue;
}

- (SMRateLimitedQueue *)getQueueForEchonest {
	static SMRateLimitedQueue *echonestQueue = nil;
	@synchronized(SMRootFactory.class) {
		if(echonestQueue == nil) {
			NSTimeInterval limit = [configuration echonestTimeBetweenRequests];
			echonestQueue = [[SMRateLimitedQueue alloc] initWithMinimumInterval:limit];
		}
	}
	
	return echonestQueue;
}

- (SMRateLimitedQueue *)getQueueForLastfm {
	static SMRateLimitedQueue *lastfmQueue = nil;
	@synchronized(SMRootFactory.class) {
		if(lastfmQueue == nil) {
			NSTimeInterval limit = [configuration lastfmTimeBetweenRequests];
			lastfmQueue = [[SMRateLimitedQueue alloc] initWithMinimumInterval:limit];
		}
	}
	
	return lastfmQueue;	
}

@end

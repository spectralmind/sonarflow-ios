#import "SFSmartistFactory.h"

#import "Configuration.h"
#import "SMArtist.h"

@implementation SFSmartistFactory

- (SMArtist *)newSmartistWithDelegate:(id<SMArtistDelegate>)delegate {
	SMArtistConfiguration *config = [SMArtistConfiguration defaultConfiguration];
	config.servicesMaskAllRequests = SMArtistWebServicesLastfm;
	config.servicesMaskVideosRequests = SMArtistWebServicesYoutube;
	config.servicesMaskImagesRequests = SMArtistWebServicesLastfm;
	
	Configuration *configuration = [Configuration sharedConfiguration];
	SMArtist *smartist = [[SMArtist alloc] initWithAWIDelegate:delegate withConfiguration:config];
	smartist.configuration.lastfmKey = [configuration lastfmApiKey];
	smartist.configuration.echonestKey = [configuration echonestApiKey];
	
	return smartist;
}

@end

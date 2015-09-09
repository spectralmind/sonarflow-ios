#import "SFAppIdentity.h"

//Convert the build setting FACEBOOK_APP_ID into a C-String
#define FACEBOOK_APP_ID_STR macrostr(FACEBOOK_APP_ID)

@implementation SFAppIdentity


- (NSURL *)rateURL {
	return [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", [SFAppIdentity iTunesAppId]]];
}

- (NSString *)storeURL {
	return [NSString stringWithFormat:@"http://itunes.apple.com/app/sonarflow/id%@", [SFAppIdentity iTunesAppId]];
}

- (NSString *)storeURLForCrossPromo {
	return [NSString stringWithFormat:@"http://itunes.apple.com/app/sonarflow/id%@", [SFAppIdentity iTunesAppIdForCrossPromo]];
}

+ (NSString *)iTunesAppId {
#if defined(SF_FREE)
	return [self iTunesAppIdFree];
#elif defined(SF_PRO)
	return [self iTunesAppIdPro];
#else
	return [self iTunesAppIdSpot];
#endif
}

+ (NSString *)iTunesAppIdForCrossPromo {
#if defined(SF_SPOTIFY)
	return [self iTunesAppIdFree];
#else
	return [self iTunesAppIdSpot];
#endif
}

+ (NSString *)iTunesAppIdFree {
	return @"382049291";
}

+ (NSString *)iTunesAppIdPro {
	return @"407248118";
}

+ (NSString *)iTunesAppIdSpot {
	return @"535452166";
}

- (NSString *)facebookAppId {
	const char *appIdCStr = FACEBOOK_APP_ID_STR;
	return [NSString stringWithUTF8String:appIdCStr];
}

@end

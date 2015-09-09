#import "SMNetworkAwareResultCache.h"
#import <Foundation/Foundation.h>
#import "Reachability.h"

@implementation SMNetworkAwareResultCache
- (SMArtistResult *)resultForCacheId:(NSString *)cacheId {
	BOOL freshObjectsOnly = [self networkAvailable];
	return [super resultForCacheId:cacheId allowExpired:!freshObjectsOnly];
}

- (BOOL)networkAvailable {
	Reachability *r = [Reachability reachabilityForInternetConnection];
	return [r isReachable];
}

@end

#import "SMResultCache.h"

@interface SMNetworkAwareResultCache : SMResultCache
- (SMArtistResult *)resultForCacheId:(NSString *)cacheId;
@end

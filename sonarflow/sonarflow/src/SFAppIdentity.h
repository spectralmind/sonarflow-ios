#import <Foundation/Foundation.h>

@interface SFAppIdentity : NSObject

+ (NSString *)iTunesAppId;
+ (NSString *)iTunesAppIdForCrossPromo;

- (NSURL *)rateURL;
- (NSString *)storeURL;
- (NSString *)facebookAppId;
- (NSString *)storeURLForCrossPromo;


@end

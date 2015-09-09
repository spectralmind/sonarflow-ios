#import <Foundation/Foundation.h>

@class LastfmSettings;

typedef void(^LastfmLoginCompletionBlock)(BOOL);

@protocol LastfmSettingsViewControllerDelegate

- (void)verifyLastfmLoginWithUsername:(NSString *)username password:(NSString *)password completion:(LastfmLoginCompletionBlock)completionBlock;
- (void)finishedWithLastfmSettings:(LastfmSettings *)settings;
- (void)didCancelLastfmSettings;
- (void)createNewLastfmAccount;

@end

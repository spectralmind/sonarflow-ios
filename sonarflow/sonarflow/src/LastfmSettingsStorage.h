#import <Foundation/Foundation.h>

@class LastfmSettings;

@interface LastfmSettingsStorage : NSObject

- (id)init;

- (LastfmSettings *)loadSettings;
- (void)storeSettings:(LastfmSettings *)settings;

@end

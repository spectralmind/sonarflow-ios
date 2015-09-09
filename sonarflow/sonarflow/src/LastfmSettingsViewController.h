#import <Foundation/Foundation.h>

#import "LastfmSettingsViewControllerDelegate.h"

@interface LastfmSettingsViewController : UINavigationController

@property (nonatomic, weak) id<LastfmSettingsViewControllerDelegate> lastfmDelegate;

- (id)initWithSettings:(LastfmSettings *)settings;

@end

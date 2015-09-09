#import <Foundation/Foundation.h>

#import "SFTableViewSection.h"

@class AdMobHandler;

@interface SFAdvertisingSection : NSObject <SFTableViewSection>

- (id)initWithAdMobHandler:(AdMobHandler *)theAdHandler;

@end

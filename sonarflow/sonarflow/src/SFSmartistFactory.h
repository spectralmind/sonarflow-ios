#import <Foundation/Foundation.h>

@class SMArtist;

@protocol SMArtistDelegate;

@interface SFSmartistFactory : NSObject
- (SMArtist *)newSmartistWithDelegate:(id<SMArtistDelegate>)delegate;

@end

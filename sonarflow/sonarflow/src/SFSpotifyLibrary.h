#import <Foundation/Foundation.h>
#import "SFMediaLibrary.h"

@class SFSpotifyPlayer;
@protocol SFSpotifyDelegate;

@interface SFSpotifyLibrary : NSObject<SFMediaLibrary>

@property (nonatomic, assign) UIViewController *mainViewController;

- (void)showLoginDialog;

@end

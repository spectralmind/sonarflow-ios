#import <Foundation/Foundation.h>

#import "GADBannerViewDelegate.h"

@interface AdMobHandler : NSObject <GADBannerViewDelegate>

@property (nonatomic, weak) UIViewController *viewController;

@property (nonatomic, strong) NSString *publisherId;

- (GADBannerView *)requestAd;

@end
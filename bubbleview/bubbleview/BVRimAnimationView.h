#import <UIKit/UIKit.h>
#import "CacheableView.h"

#import "BVRimAnimationState.h"

@interface BVRimAnimationView : UIView <CacheableView>

- (void)setRimIndicatorImage:(UIImage *)rimIndicatorImage;

- (void)setRimAnimationState:(BVRimAnimationState)state offset:(NSTimeInterval)offset;


@end

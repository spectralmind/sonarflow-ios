#import "BVResources.h"

@interface BVResources ()

#pragma mark Hidden from library user
@property (nonatomic, readonly) UIImage *labelBackgroundImage;
@property (nonatomic, readonly) UIImage *labelCountBackgroundImage;
@property (nonatomic, readonly) UIImage *glowImage;
@property (nonatomic, readonly) UIImage *rimIndicatorImage;

- (NSArray *)bubbleBackgroundSizesForType:(BubbleType)type;
- (NSArray *)bubbleBackgroundsForType:(BubbleType)type color:(UIColor *)color;
- (UIImage *)labelBackgroundForColor:(UIColor *)color;

@end

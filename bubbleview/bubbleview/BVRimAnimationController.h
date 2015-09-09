#import <Foundation/Foundation.h>

#import "BVRimAnimationState.h"

@class BubbleView;
@protocol BVRimAnimationControllerDelegate;

@interface BVRimAnimationController : NSObject

@property (nonatomic, strong) NSArray *keyPath;
@property (nonatomic, assign) BVRimAnimationState state;
@property (nonatomic, weak) id<BVRimAnimationControllerDelegate> delegate;

- (NSTimeInterval)currentAnimationPlayDuration;
- (BOOL)shouldHaveRimAnimation:(NSArray *)bubbleKeyPath;

- (void)addBubbleView:(BubbleView *)view;
- (void)removeBubbleView:(BubbleView *)view;

@end

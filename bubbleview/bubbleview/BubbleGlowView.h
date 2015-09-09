#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BubbleGlowView : UIView

- (void)setBubbleGlowImage:(UIImage *)bubbleGlowImage;

- (void)reset;

- (void)detatchFromCurrentBubble;

- (void)startTouchAnimation;

- (void)endTouchAnimation;

@end

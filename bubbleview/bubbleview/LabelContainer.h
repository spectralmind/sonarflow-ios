#import <Foundation/Foundation.h>

@class BubbleLabelView;

@protocol LabelContainer <NSObject>

- (void)addLabelView:(BubbleLabelView *)labelView;
- (CGPoint)labelPointFromPoint:(CGPoint)point inView:(UIView *)view;

@end

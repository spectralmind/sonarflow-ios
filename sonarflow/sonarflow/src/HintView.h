#import <UIKit/UIKit.h>

@interface HintView : UIView

@property (nonatomic, strong) NSString *text;
@property (nonatomic, readonly) CGFloat arrowOffsetHorizontal;

- (void)resizeToFitTextForWidth:(CGFloat)maxWidth;

@end

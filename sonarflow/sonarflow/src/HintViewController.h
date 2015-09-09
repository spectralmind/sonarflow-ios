#import <Foundation/Foundation.h>

typedef void(^HintTapDelegateBlock)();

@interface HintViewController : NSObject

@property (weak, nonatomic, readonly) UIView *view;
@property (nonatomic, strong) UIView *referenceView;
@property (nonatomic, assign) CGFloat maxWidth;

- (void)showHint:(NSString *)hint forDuration:(NSTimeInterval)duration withTapDelegate:(HintTapDelegateBlock)theTapDelegateBlock;
- (void)hideHint;

@end

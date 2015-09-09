#import <UIKit/UIKit.h>

@protocol SFZoomHintViewDelegate;

@interface SFZoomHintView : UIView

@property (nonatomic, weak) id<SFZoomHintViewDelegate> delegate;

- (void)startAnimation;

@end


@protocol SFZoomHintViewDelegate <NSObject>

- (void)zoomHintViewDidFinishAnimation:(SFZoomHintView *)zoomHintView;

@end
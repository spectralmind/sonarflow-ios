#import <UIKit/UIKit.h>

typedef enum {
	InfoIpadViewSectionStateLoading,
	InfoIpadViewSectionStateFailed,
	InfoIpadViewSectionStateLoaded,
} InfoIpadViewSectionState;

@protocol InfoIpadViewCloseDelegate;
@protocol InfoIpadViewDelegate;

@interface InfoIpadView : UIView

@property (nonatomic, weak) id<InfoIpadViewDelegate> infoIpadViewDelegate;

- (void)reloadData;
- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;
- (void)flashScrollIndicators;

- (void)addFacebookButton:(UIButton *)fbButton andTwitterButton:(UIButton *)twButton;

@end


@protocol InfoIpadViewCloseDelegate <NSObject>

- (void)closeView;

@end

@protocol InfoIpadViewDelegate <InfoIpadViewCloseDelegate>

@required
- (NSString *)infoIpadViewStringForTitle:(InfoIpadView *)infoIpadView;
- (NSUInteger)infoIpadViewNumberOfRows:(InfoIpadView *)infoIpadView;
- (CGFloat)infoIpadViewSpaceBetweenRows:(InfoIpadView *)infoIpadView;
- (CGFloat)infoIpadView:(InfoIpadView *)infoIpadView heightForContentOfRowWithIndex:(NSUInteger)index;
- (NSString *)infoIpadView:(InfoIpadView *)infoIpadView titleForRowWithIndex:(NSUInteger)index;
- (UIView *)infoIpadView:(InfoIpadView *)infoIpadView contentViewForRowWithIndex:(NSUInteger)index;

@optional
- (InfoIpadViewSectionState)infoIpadView:(InfoIpadView *)infoIpadView stateOfRowWithIndex:(NSUInteger)index;
- (NSString *)infoIpadView:(InfoIpadView *)infoIpadView failedMessageOfRowWithIndex:(NSUInteger)index;

@end

#import <UIKit/UIKit.h>

@interface ActivityLabelView : UIView

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, assign) CGSize shadowOffset;

@property (nonatomic, assign, getter=isActivityIndicatorVisible) BOOL activityIndicatorVisible;

@end

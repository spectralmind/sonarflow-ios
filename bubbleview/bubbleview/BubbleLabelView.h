#import <UIKit/UIKit.h>
#import "CacheableView.h"

@class BubbleView;

@interface BubbleLabelView : UIView <CacheableView>

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, weak) BubbleView *owner;

- (id)initWithFont:(UIFont *)font countFont:(UIFont *)countFont countBackground:(UIImage *)countBackgroundImage countVisible:(BOOL)countVisible;

- (void)setLabelImage:(UIImage *)backgroundImage;

- (void)setCount:(NSString *)count;

@end

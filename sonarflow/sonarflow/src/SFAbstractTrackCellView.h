#import <UIKit/UIKit.h>

@interface SFAbstractTrackCellView : UITableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, strong) UIView *leftDetailView;
@property (nonatomic, strong, readonly)	UIView *durationAccessoryView;
@property (nonatomic, strong, readonly)	UILabel *trackDurationLabel;
@property (nonatomic, readonly) NSUInteger trackDurationWidth;
@property (nonatomic, readonly) NSUInteger nowPlayingRightPadding;
@property (nonatomic, readonly, assign) NSUInteger outerPadding;

- (void)setNowPlayingImage:(UIImage *)nowPlayingImage;
- (void)setTrackDuration:(NSNumber *)trackDuration;

- (CGRect)preventAccessoryHorizontalLineOverlap:(CGRect)accessoryFrame;

@end

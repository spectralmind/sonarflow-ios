#import <UIKit/UIKit.h>
#import "SMArtistVideo.h"

@protocol ScrollingVideoViewDelegate;

@interface ScrollingVideoView : UIScrollView

@property (nonatomic, weak) id<ScrollingVideoViewDelegate> scrollingVideoViewDelegate;

- (id)initWithFrame:(CGRect)frame horizontallyScrollingWithVideoSpacing:(CGFloat)imageSpacing;
- (id)initWithFrame:(CGRect)frame verticallyScrollingWithVideoSpacing:(CGFloat)imageSpacing;

- (void)reloadData;

@end


@protocol ScrollingVideoViewDelegate <NSObject>

- (NSUInteger)scrollingVideoViewNumberOfVideos:(ScrollingVideoView *)scrollingNetworkImageView;
- (SMArtistVideo *)scrollingVideoView:(ScrollingVideoView *)scrollingNetworkImageView videoWithIndex:(NSUInteger)index;
- (CGSize)scrollingVideoViewSizeOfVideos:(ScrollingVideoView *)scrollingNetworkImageView;
- (NSString *)artistNameForScrollingVideoView:(ScrollingVideoView *)scrollingVideoView;
@end

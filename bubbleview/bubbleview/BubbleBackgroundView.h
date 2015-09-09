#import <UIKit/UIKit.h>
#import "CacheableView.h"

@interface BubbleBackgroundView : UIView <CacheableView> {
	@private
	NSArray *sizes;
	NSArray *imageViews;
	NSArray *images;
}

- (id)initWithSizes:(NSArray *)theSizes;

- (void)setImages:(NSArray *)newImages;

@end

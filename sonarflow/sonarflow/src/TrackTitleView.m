#import "TrackTitleView.h"

#import "SFMediaItemHelper.h"
#import "SFMediaItem.h"

@interface TrackTitleView ()

- (void)showPlaceholderView;
- (void)createPlaceholderView;
- (void)hidePlaceholderView;

@end

@implementation TrackTitleView {
	UIView *placeholderView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
    }
    return self;
}


- (void)showInformationForMediaItem:(id<SFMediaItem>)mediaItem {
	if(mediaItem == nil) {
		self.titleView.hidden = YES;
		self.subtitleView.hidden = YES;
		[self showPlaceholderView];
		return;
	}
	
	NSString *subtitle = [SFMediaItemHelper summaryForMediaItem:mediaItem
										  includingAlbum:YES
												  artist:YES];
	
	self.titleView.hidden = NO;
	self.subtitleView.hidden = NO;
	self.titleView.text = [mediaItem name];
	self.subtitleView.text = subtitle;
	[self hidePlaceholderView];
}

- (void)showPlaceholderView {
	if(placeholderView == nil) {
		[self createPlaceholderView];
	}
	placeholderView.hidden = NO;
}

- (void)createPlaceholderView {
	UIImage *image = [UIImage imageNamed:@"sonarflow_logo_head.png"];
	UIImageView *view = [[UIImageView alloc] initWithImage:image];
	view.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
	view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |
		UIViewAutoresizingFlexibleBottomMargin |
		UIViewAutoresizingFlexibleLeftMargin |
		UIViewAutoresizingFlexibleRightMargin;
	[self addSubview:view];
	placeholderView = view;
}

- (void)hidePlaceholderView {
	placeholderView.hidden = YES;
}

@end

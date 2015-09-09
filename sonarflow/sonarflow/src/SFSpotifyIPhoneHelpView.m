#import "SFSpotifyIPhoneHelpView.h"

#import "UIScrollView+PageScrollView.h"

static const NSUInteger kNumPages = 4;
static const CGFloat kHeaderHeight = 40;

@implementation SFSpotifyIPhoneHelpView {
	@private
	CGRect oldBounds;
}

- (void)awakeFromNib {
    [super awakeFromNib];
	
	[self.scrollView addSubview:self.page1];
	[self.scrollView addSubview:self.page2];
	[self.scrollView addSubview:self.page3];
	[self.scrollView addSubview:self.page4];
	oldBounds = CGRectZero;
	self.pageControl.numberOfPages = kNumPages;
}


@synthesize versionLabel;

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	
	CGSize pageSize = self.scrollView.frame.size;
	CGSize contentSize = CGSizeMake(pageSize.width * kNumPages, pageSize.height);
	[self.scrollView setContentSize:contentSize];
	
	NSUInteger page = self.pageControl.currentPage;
	[self.scrollView scrollToPage:page animated:NO];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	if(CGRectEqualToRect(oldBounds, self.bounds)) {
		return;
	}
	
	oldBounds = self.bounds;
	
	CGSize pageSize = self.scrollView.frame.size;	
	CGRect pageFrame = CGRectMake(0, 0, pageSize.width, pageSize.height);
	self.page1.frame = pageFrame;
	pageFrame.origin.x += pageFrame.size.width;
	self.page2.frame = pageFrame;
	pageFrame.origin.x += pageFrame.size.width;
	self.page3.frame = pageFrame;
	pageFrame.origin.x += pageFrame.size.width;
	self.page4.frame = pageFrame;
	
	if(self.bounds.size.width > self.bounds.size.height) {
		[self landscapeLayout];
	}
	else {
		[self portraitLayout];
	}
}

- (void)landscapeLayout {
	CGFloat width = self.help11.frame.size.width;
	CGFloat widthSum = 4 * width;
	CGFloat padding = (self.page1.bounds.size.width - widthSum) / 8;
	CGFloat availableHeight = self.page1.bounds.size.height - kHeaderHeight;
	CGPoint center1 = CGPointMake(padding + width * 0.5, kHeaderHeight + availableHeight * 0.5);
	CGPoint center2 = CGPointMake(center1.x + width + 2 * padding, center1.y);
	CGPoint center3 = CGPointMake(center2.x + width + 2 * padding, center1.y);
	CGPoint center4 = CGPointMake(center3.x + width + 2 * padding, center1.y);
	
	self.help11.center = center1;
	self.help12.center = center2;
	self.help13.center = center3;
	self.help14.center = center4;
	self.help21.center = center1;
	self.help22.center = center2;
	self.help23.center = center3;
	self.help24.center = center4;
	self.help31.center = center1;
	self.help32.center = center2;
	self.help34.center = center3;
	
	CGRect spotifyFrame = self.help32.frame;
	spotifyFrame.origin.y = self.help31.frame.origin.y;
	self.help32.frame = spotifyFrame;
}

- (void)portraitLayout {
	CGFloat width = self.help11.frame.size.width;
	CGFloat height = self.help11.frame.size.height;
	CGFloat widthSum = 2 * width;
	CGFloat heightSum = 2 * height;
	CGFloat hPadding = (self.page1.bounds.size.width - widthSum) / 4;
	CGFloat vPadding = (self.page1.bounds.size.height - kHeaderHeight - heightSum) / 4;
	CGPoint center1 = CGPointMake(hPadding + width * 0.5, kHeaderHeight + vPadding + height * 0.5);
	CGPoint center2 = CGPointMake(center1.x + width + 2 * hPadding, center1.y);
	CGPoint center3 = CGPointMake(center1.x, center1.y + height + 2 * vPadding);
	CGPoint center4 = CGPointMake(center2.x, center3.y);
	
	self.help11.center = center1;
	self.help12.center = center2;
	self.help13.center = center3;
	self.help14.center = center4;
	self.help21.center = center1;
	self.help22.center = center2;
	self.help23.center = center3;
	self.help24.center = center4;
	
	self.help31.center = center1;
	self.help32.center = center2;
	self.help34.center = center4;
	
	CGRect spotifyFrame = self.help32.frame;
	spotifyFrame.origin.y = self.help31.frame.origin.y;
	self.help32.frame = spotifyFrame;	
}

- (IBAction)changePage:(id)sender {
	int page = self.pageControl.currentPage;
	[self.scrollView scrollToPage:page animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self updatePageControlFromScrollView];	
}

- (void)updatePageControlFromScrollView {
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	self.pageControl.currentPage = page;
}

- (void)scrollToPartners {
	[self.scrollView scrollToPage:3 animated:YES];
}

@end

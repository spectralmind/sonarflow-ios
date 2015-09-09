#import "SFAbstractTrackCellView.h"
#import "Formatter.h"

@interface SFAbstractTrackCellView ()

@property (nonatomic, readwrite, assign) NSUInteger outerPadding;
@property (nonatomic, assign) NSUInteger nowPlayingLeftPadding;
@property (nonatomic, assign) NSUInteger nowPlayingWidth;
@property (nonatomic, assign) NSUInteger nowPlayingRightPadding;
@property (nonatomic, assign) NSUInteger trackDurationWidth;
@property (nonatomic, assign) NSUInteger leftDetailViewWidth;
@property (nonatomic, assign) NSUInteger leftDetailViewPadding;

@property (nonatomic, strong, readonly) UIImageView *nowPlayingImageView;

@end

@implementation SFAbstractTrackCellView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	if((self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier])) {
		[self setDefaults];
		self.accessoryView = self.durationAccessoryView;
    }
    return self;
}



- (void)setLeftDetailView:(UIView *)newLeftDetailView {
	if(_leftDetailView == newLeftDetailView) {
		return;
	}
	[_leftDetailView removeFromSuperview];
	_leftDetailView = newLeftDetailView;

	CGSize cellSize = self.contentView.bounds.size;
	_leftDetailView.frame = CGRectMake(self.outerPadding, 0, self.leftDetailViewWidth, cellSize.height);
	_leftDetailView.autoresizingMask = UIViewAutoresizingFlexibleHeight | 
		UIViewAutoresizingFlexibleRightMargin;
	_leftDetailView.backgroundColor = self.backgroundColor;
	[self.contentView addSubview:_leftDetailView];
	[self setNeedsLayout];
}

@synthesize nowPlayingImageView = _nowPlayingImageView;
- (UIImageView *)nowPlayingImageView {
	if(_nowPlayingImageView == nil) {
		CGSize accessorySize = self.durationAccessoryView.bounds.size;
		CGRect viewFrame = CGRectMake(self.nowPlayingLeftPadding, 0, self.nowPlayingWidth, accessorySize.height);
		_nowPlayingImageView = [[UIImageView	alloc] initWithFrame:viewFrame];
		_nowPlayingImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | 
		UIViewAutoresizingFlexibleBottomMargin |
		UIViewAutoresizingFlexibleRightMargin;
		_nowPlayingImageView.contentMode = UIViewContentModeCenter;
		_nowPlayingImageView.backgroundColor = self.backgroundColor;
		
		[self.durationAccessoryView addSubview:_nowPlayingImageView];
	}
	
	return _nowPlayingImageView;
}

@synthesize trackDurationLabel = _trackDurationLabel;
- (UILabel *)trackDurationLabel {
	if(_trackDurationLabel == nil) {
		CGSize accessorySize = self.durationAccessoryView.bounds.size;
		CGRect viewFrame = CGRectMake(accessorySize.width - self.trackDurationWidth - self.outerPadding, 0,
									  self.trackDurationWidth, accessorySize.height);
		_trackDurationLabel = [[UILabel alloc] initWithFrame:viewFrame];
		_trackDurationLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | 
		UIViewAutoresizingFlexibleLeftMargin;
		_trackDurationLabel.backgroundColor = self.backgroundColor;
		_trackDurationLabel.textAlignment = UITextAlignmentRight;
		_trackDurationLabel.adjustsFontSizeToFitWidth = YES;
		
		[self.durationAccessoryView addSubview:_trackDurationLabel];
	}
	return _trackDurationLabel;
}

@synthesize durationAccessoryView = _durationAccessoryView;
- (UIView *)durationAccessoryView {
	if(_durationAccessoryView == nil) {
		CGSize cellSize = self.bounds.size;
		CGFloat defaultWidth = self.trackDurationWidth + self.outerPadding;
		CGRect viewFrame = CGRectMake(cellSize.width - defaultWidth, 0,
									  defaultWidth, cellSize.height);
		CGRect correctedFrame = [self preventAccessoryHorizontalLineOverlap:viewFrame];
		_durationAccessoryView = [[UIView alloc] initWithFrame:correctedFrame];
		_durationAccessoryView.backgroundColor = self.backgroundColor;
	}
	
	return _durationAccessoryView;
}

- (void)setDefaults {
	self.outerPadding = 10;
	self.leftDetailViewWidth = 25;
	self.leftDetailViewPadding = 10;
	self.nowPlayingLeftPadding = 2;
	self.nowPlayingWidth = 22;
	self.nowPlayingRightPadding = 2;
	self.trackDurationWidth = 50;
}

- (BOOL)hasLeftDetailView {
	return self.leftDetailView != nil && self.leftDetailView.hidden == NO;
}

- (CGRect)preventAccessoryHorizontalLineOverlap:(CGRect)accessoryFrame {
	return CGRectInset(accessoryFrame, 0, 1);
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGFloat width = self.outerPadding;
	if([self hasLeftDetailView]) {
		width += self.leftDetailViewWidth + self.leftDetailViewPadding;
	}

	//Adjust other labels
	CGSize contentSize = self.contentView.bounds.size;
	CGRect otherFrame;
	CGFloat delta;
	
	otherFrame = self.textLabel.frame;
	delta = width - otherFrame.origin.x;
	otherFrame.origin.x += delta;
	otherFrame.size.width = contentSize.width - otherFrame.origin.x;
	self.textLabel.frame = otherFrame;
	
	otherFrame = self.detailTextLabel.frame;
	delta = width - otherFrame.origin.x;
	otherFrame.origin.x += delta;
	otherFrame.size.width = contentSize.width - otherFrame.origin.x;
	self.detailTextLabel.frame = otherFrame;
}

- (void)setNowPlayingImage:(UIImage *)nowPlayingImage {
	if(nowPlayingImage != nil) {
		self.nowPlayingImageView.image = nowPlayingImage;
		self.nowPlayingImageView.hidden = NO;
	}
	else {
		self.nowPlayingImageView.image = nil;
		self.nowPlayingImageView.hidden = YES;
	}
	[self adjustAccessoryView];
}

- (void)setTrackDuration:(NSNumber *)trackDuration {
	if(trackDuration != nil) {
		self.trackDurationLabel.text = [Formatter formatDuration:[trackDuration floatValue]];
	}
	else {
		self.trackDurationLabel.text = nil;
	}
}

- (void)setBackgroundColor:(UIColor *)newColor {
	[super setBackgroundColor:newColor];
	
	self.nowPlayingImageView.backgroundColor = newColor;
	self.leftDetailView.backgroundColor = newColor;
	self.trackDurationLabel.backgroundColor = newColor;
	self.durationAccessoryView.backgroundColor = newColor;
}

#pragma mark -
#pragma mark Private Methods

- (void)adjustAccessoryView {
	CGRect accessoryFrame = self.durationAccessoryView.frame;
	CGFloat width = self.trackDurationWidth + self.outerPadding;
	if(self.nowPlayingImageView != nil && !self.nowPlayingImageView.hidden) {
		width += self.nowPlayingLeftPadding + self.nowPlayingWidth + self.nowPlayingRightPadding;
	}
	accessoryFrame.size.width = width;
	self.durationAccessoryView.frame = accessoryFrame;
}

@end

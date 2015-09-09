#import "SFITunesTrackCellView.h"
#import "ImageFactory.h"

#import "SFAffiliateLinkGenerator.h"

static NSString *const kTrackCellIdentifier = @"ITunesTrackCellIdentifier";
static const CGFloat kButtonWidth = 25;

@implementation SFITunesTrackCellView {
	ImageFactory *imageFactory;
	UIView *durationAccessoryView;
	NSURL *buyUrl;
}

+ (SFITunesTrackCellView *)trackCellForTableView:(UITableView *)tableView withBuyUrl:(NSURL *)buyUrl imageFactory:(ImageFactory *)imageFactory {
    SFITunesTrackCellView *cell = (SFITunesTrackCellView *)[tableView dequeueReusableCellWithIdentifier:kTrackCellIdentifier];
	NSAssert(cell == nil || [cell isKindOfClass:[SFITunesTrackCellView class]], @"Unexpected track cell class type");
    if(cell == nil) {
		cell = [[SFITunesTrackCellView alloc] initWithReuseIdentifier:kTrackCellIdentifier buyUrl:buyUrl imageFactory:imageFactory];
    }
	return cell;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier buyUrl:(NSURL *)theBuyUrl imageFactory:(ImageFactory *)theImageFactory {
	imageFactory = theImageFactory;		
	self = [super initWithReuseIdentifier:reuseIdentifier];
	if(self == nil) {
		return nil;
	}
	
	buyUrl = theBuyUrl;
	return self;
}



- (UIView *)durationAccessoryView {
	if(durationAccessoryView == nil) {
		CGSize cellSize = self.bounds.size;
		CGRect viewFrame = CGRectMake(cellSize.width - self.trackDurationWidth, 0,
									  self.trackDurationWidth, cellSize.height);
		CGRect correctedFrame = [self preventAccessoryHorizontalLineOverlap:viewFrame];
		durationAccessoryView = [[UIView alloc] initWithFrame:correctedFrame];
		durationAccessoryView.backgroundColor = self.backgroundColor;
		
		UIImage *buyImage = [imageFactory buyOnItunesImage];
		
		CGRect buttonRect = CGRectMake(viewFrame.size.width - self.trackDurationWidth - self.outerPadding, 0, buyImage.size.width, viewFrame.size.height);

		UIButton *buyButton = [[UIButton alloc] initWithFrame:buttonRect];
		[buyButton setImage:buyImage forState:UIControlStateNormal];
		[buyButton addTarget:self action:@selector(tappedBuy:) forControlEvents:UIControlEventTouchUpInside];
		
		buyButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		[durationAccessoryView addSubview:buyButton];
	}
	
	return durationAccessoryView;
}

- (void)tappedBuy:(id)sender {
	NSURL *affiliateLink = [SFAffiliateLinkGenerator affiliateLink:buyUrl];
	NSLog(@"want to buy track from %@", affiliateLink);
	[[UIApplication sharedApplication] openURL:affiliateLink];
}

- (UILabel *)trackDurationLabel {
	return nil;
}

- (NSUInteger)nowPlayingRightPadding {
	return 6;
}

@end

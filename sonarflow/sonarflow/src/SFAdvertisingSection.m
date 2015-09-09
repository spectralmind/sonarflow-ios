#import "SFAdvertisingSection.h"

#import "AdMobHandler.h"
#import "GADBannerView.h"

@interface SFAdvertisingSection ()

@property (nonatomic, strong) UIView *adView;

@end


@implementation SFAdvertisingSection {
	AdMobHandler *adHandler;
}

- (id)init {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)initWithAdMobHandler:(AdMobHandler *)theAdHandler {
    self = [super init];
    if (self) {
		adHandler = theAdHandler;
    }
    return self;
}


@synthesize title;
@synthesize delegate;

- (NSUInteger)numberOfRows {
	return 1;
}

- (CGFloat)heightForRow:(NSUInteger)row inTableView:(UITableView *)tableView {
	return tableView.rowHeight;
}

- (UITableViewCell *)cellForRow:(NSUInteger)row inTableView:(UITableView *)tableView {
	BOOL newAdView = NO;
	if(self.adView == nil) {
		self.adView = [adHandler requestAd];
		self.adView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
		UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		newAdView = (self.adView != nil);
	}
	
	static NSString *AdCellIdentifier = @"AdCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AdCellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc]
				 initWithStyle:UITableViewCellStyleDefault
				 reuseIdentifier:AdCellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		self.adView.center = CGPointMake(cell.bounds.size.width * 0.5, cell.bounds.size.height * 0.5);
		[cell.contentView addSubview:self.adView];
	}
	else if(newAdView) {
		[cell.contentView addSubview:self.adView];
	}
	
	return cell;
}

- (NSObject<SFMediaItem> *)mediaItemForRow:(NSUInteger)row {
	return nil;
}

- (BOOL)canSelectRow:(NSUInteger)row {
	return YES;
}

- (BOOL)hasDetailViewControllerForRow:(NSUInteger)row {
	return NO;
}

- (UIViewController *)detailViewControllerForRow:(NSUInteger)row factory:(MediaViewControllerFactory *)factory {
	return nil;
}

- (void)handleSelectRow:(NSUInteger)row {
}

@end

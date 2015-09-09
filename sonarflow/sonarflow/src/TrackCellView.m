#import "TrackCellView.h"
#import "Formatter.h"

static NSString *const kTrackCellIdentifier = @"TrackCellIdentifier";
static const CGFloat KTrackNumberWidth = 25;

@interface TrackCellView ()

@property (nonatomic, readonly)	UILabel *trackNumberLabel;

@end

@implementation TrackCellView {
}


+ (TrackCellView *)trackCellForTableView:(UITableView *)tableView {
    TrackCellView *cell = (TrackCellView *)[tableView dequeueReusableCellWithIdentifier:kTrackCellIdentifier];
	NSAssert(cell == nil || [cell isKindOfClass:[TrackCellView class]], @"Unexpected track cell class type");
    if(cell == nil) {
		cell = [[TrackCellView alloc] initWithReuseIdentifier:kTrackCellIdentifier];
    }
	return cell;
}

@synthesize trackNumberLabel = _trackNumberLabel;
- (UILabel *)trackNumberLabel {
	if(_trackNumberLabel == nil) {
		_trackNumberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_trackNumberLabel.textAlignment = UITextAlignmentRight;
		self.leftDetailView = _trackNumberLabel;
	}
	
	return _trackNumberLabel;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
	if((self = [super initWithReuseIdentifier:reuseIdentifier])) {
    }
    return self;
}


- (void)setTrackNumber:(NSNumber *)trackNumber {
	self.trackNumberLabel.text = [trackNumber stringValue];
	self.trackNumberLabel.hidden = ([self.trackNumberLabel.text length] == 0);
	[self setNeedsLayout];
}

@end

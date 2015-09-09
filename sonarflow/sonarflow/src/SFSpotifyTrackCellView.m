#import "SFSpotifyTrackCellView.h"
#import "ImageFactory.h"

static NSString *const kSpotifyTrackCellIdentifier = @"SpotifyTrackCellIdentifier";
static const CGFloat kButtonWidth = 25;

@implementation SFSpotifyTrackCellView {
	ImageFactory *imageFactory;
	UIButton *starredButton;
}

+ (SFSpotifyTrackCellView *)trackCellForTableView:(UITableView *)tableView withImageFactory:(ImageFactory *)imageFactory {
    SFSpotifyTrackCellView *cell = (SFSpotifyTrackCellView *)[tableView dequeueReusableCellWithIdentifier:kSpotifyTrackCellIdentifier];
	NSAssert(cell == nil || [cell isKindOfClass:[SFSpotifyTrackCellView class]], @"Unexpected track cell class type");
    if(cell == nil) {
		cell = [[SFSpotifyTrackCellView alloc] initWithReuseIdentifier:kSpotifyTrackCellIdentifier imageFactory:imageFactory];
    }
	return cell;
}
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier imageFactory:(ImageFactory *)theImageFactory {
	self = [super initWithReuseIdentifier:reuseIdentifier];
	if (self) {
		imageFactory = theImageFactory;
		starredButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[starredButton addTarget:self action:@selector(onStarredButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		self.leftDetailView = starredButton;
	}
	return self;
}

- (void)setStarred:(BOOL)newStarred {	
	_starred = newStarred;
	UIImage *image = (_starred ? [imageFactory starIcon] : [imageFactory starIconInactive]);
	[starredButton setImage:image forState:UIControlStateNormal];
}

- (IBAction)onStarredButtonTapped:(id)sender {
	self.setStarredBlock(!self.starred);
}

@end

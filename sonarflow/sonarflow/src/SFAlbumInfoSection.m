#import "SFAlbumInfoSection.h"

#import "SFMediaItem.h"

static NSString * const kAlbumInfoCellIdentifier = @"AlbumInfoCell";

@interface SFAlbumInfoSection ()

@end

@implementation SFAlbumInfoSection {
	NSObject<SFMediaItem> *mediaItem;
}

- (id)initWithMediaItem:(NSObject<SFMediaItem> *)theMediaItem {
    self = [super init];
    if (self) {
		mediaItem = theMediaItem;
    }
    return self;
}


@synthesize delegate;
@synthesize title;
@synthesize albumHeaderCell;

- (NSUInteger)numberOfRows {
	if([self isVisible] == NO) {
		return 0;
	}

	return 1;
}

- (BOOL)isVisible {
	return [mediaItem mayHaveImage];
}

- (CGFloat)heightForRow:(NSUInteger)row inTableView:(UITableView *)tableView {
	return [self formattedHeaderCell].frame.size.height;
}

- (UITableViewCell *)cellForRow:(NSUInteger)row inTableView:(UITableView *)tableView {
	return [self formattedHeaderCell];
}

- (UITableViewCell *)formattedHeaderCell {
	if(self.albumHeaderCell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"AlbumHeaderCell" owner:self options:nil];
		UIImageView *coverView = (UIImageView *)[self.albumHeaderCell viewWithTag:1];
		UILabel *albumNameLabel = (UILabel *)[self.albumHeaderCell viewWithTag:2];
		UILabel *artistNameLabel = (UILabel *)[self.albumHeaderCell viewWithTag:3];
		CGSize viewSize = coverView.frame.size;
		coverView.image = [mediaItem imageWithSize:viewSize];
		albumNameLabel.text = [mediaItem name];
		if([mediaItem respondsToSelector:@selector(artistName)]) {
			artistNameLabel.text = [mediaItem artistName];
		}
		else {
			artistNameLabel.text = nil;
		}
	}
	
	return albumHeaderCell;
}

- (NSObject<SFMediaItem> *)mediaItemForRow:(NSUInteger)row {
	return nil;
}

- (BOOL)canSelectRow:(NSUInteger)row {
	return NO;
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

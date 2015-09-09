#import "SFMediaChildrenSection.h"

#import "SFMediaItem.h"
#import "SFMediaItemHelper.h"

static NSString * const kMediaItemCellIdentifier = @"SFMediaItemCell";
static const CGSize kCoverSize = { 43, 43 };

@implementation SFMediaChildrenSection

@synthesize showImage;

- (UITableViewCell *)cellForChildItem:(id<SFMediaItem>)childItem atRow:(NSUInteger)row inTableView:(UITableView *)tableView {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMediaItemCellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kMediaItemCellIdentifier];
    }
	[self configureCell:cell forChildItem:childItem];
	return cell;
}

- (void)configureCell:(UITableViewCell *)cell forChildItem:(id<SFMediaItem>)childItem {
	cell.textLabel.text = childItem.name;
	cell.detailTextLabel.text = [SFMediaItemHelper summaryForMediaItem:childItem includingAlbum:self.showAlbumName	artist:self.showArtistName];
	if(self.showImage) {
		if([childItem mayHaveImage]) {
			cell.imageView.image = [childItem imageWithSize:kCoverSize];
		}
		else {
			cell.imageView.image = nil;
		}
	}
	
	if([childItem hasDetailViewController]) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
}


@end

#import "SFArtistInfoSection.h"

#import "Notifications.h"
#import "SFMediaItem.h"

static NSString * const kArtistInfoCellIdentifier = @"ArtistInfoCell";

@interface SFArtistInfoSection ()

@end

@implementation SFArtistInfoSection {
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

- (NSUInteger)numberOfRows {
	return 1;
}

- (CGFloat)heightForRow:(NSUInteger)row inTableView:(UITableView *)tableView {
	return tableView.rowHeight;
}

- (UITableViewCell *)cellForRow:(NSUInteger)row inTableView:(UITableView *)tableView {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kArtistInfoCellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kArtistInfoCellIdentifier];
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
    }
	cell.textLabel.text = NSLocalizedString(@"Artist Info",
											@"Title for artist info row");
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
	[self postShowArtistInfoNotification];
}

- (void)postShowArtistInfoNotification {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:mediaItem forKey:SFShowArtistInfoNotificationArtistKey];
	[[NSNotificationCenter defaultCenter] postNotificationName:SFShowArtistInfoNotification object:self userInfo:userInfo];
}


@end

#import "SFAbstractMediaItemSection.h"

#import "SFMediaItem.h"
#import "SFArrayObserver.h"

static NSString * const kLoadingCellIdentifier = @"kLoadingCellIdentifier";
static NSString * const kNoChildrenCellIdentifier = @"kNoChildrenCellIdentifier";

@interface SFAbstractMediaItemSection () <SFArrayObserverDelegate>

@end

@implementation SFAbstractMediaItemSection {
	@private
	NSObject<SFMediaItem> *mediaItem;
	SFArrayObserver *childrenObserver;
	BOOL updating;
}

- (id)initWithMediaItem:(NSObject<SFMediaItem> *)theMediaItem {
    self = [super init];
    if (self) {
		mediaItem = theMediaItem;
		childrenObserver = [[SFArrayObserver alloc] initWithObject:mediaItem keyPath:@"children" delegate:self];
    }
    return self;
}


@synthesize title;
@synthesize delegate;
@synthesize showAlbumName;
@synthesize showArtistName;
@synthesize mediaItem;

- (NSUInteger)numberOfRows {
	if([self isLoading] || [self isEmpty]) {
		return 1;
	}
	return [mediaItem.children count];
}

- (BOOL)isLoading {
	return mediaItem.children == nil;
}

- (BOOL)isEmpty {
	return [mediaItem.children count] == 0;
}

- (CGFloat)heightForRow:(NSUInteger)row inTableView:(UITableView *)tableView {
	return tableView.rowHeight;
}

- (UITableViewCell *)cellForRow:(NSUInteger)row inTableView:(UITableView *)tableView {
	if([self isLoading]) {
		return [self loadingCellForTableView:tableView];
	}
	if([self isEmpty]) {
		return [self noChildrenCellForTableView:tableView];
	}

	return [self cellForChildItem:[self mediaItemForRow:row] atRow:row inTableView:tableView];
}

- (UITableViewCell *)loadingCellForTableView:(UITableView *)tableView {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLoadingCellIdentifier];
    if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLoadingCellIdentifier];
		UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
				UIViewAutoresizingFlexibleTopMargin |
				UIViewAutoresizingFlexibleBottomMargin;
		activityView.center = CGPointMake(CGRectGetMidX(cell.contentView.bounds),
										  CGRectGetMidY(cell.contentView.bounds));
		[cell.contentView addSubview:activityView];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		[activityView startAnimating];
    }
	return cell;
}

- (UITableViewCell *)noChildrenCellForTableView:(UITableView *)tableView {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNoChildrenCellIdentifier];
    if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNoChildrenCellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.textColor = [UIColor lightGrayColor];
		cell.textLabel.text = NSLocalizedString(@"No tracks available", @"Placeholder label when a list does not contain any children");
    }
	return cell;
}

- (UITableViewCell *)cellForChildItem:(id<SFMediaItem>)childItem atRow:(NSUInteger)row inTableView:(UITableView *)tableView {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSObject<SFMediaItem> *)mediaItemForRow:(NSUInteger)row {
	NSAssert([self isLoading] == NO && [self isEmpty] == NO, @"Can not get mediaItem while loading or empty");
	return [mediaItem.children objectAtIndex:row];
}

- (BOOL)canSelectRow:(NSUInteger)row {
	if([self isLoading] || [self isEmpty]) {
		return NO;
	}

	return YES;
}

- (BOOL)hasDetailViewControllerForRow:(NSUInteger)row {
	return [[self mediaItemForRow:row] hasDetailViewController];
}

- (UIViewController *)detailViewControllerForRow:(NSUInteger)row factory:(MediaViewControllerFactory *)factory {
	return [[self mediaItemForRow:row] createDetailViewControllerWithFactory:factory];
}

- (void)handleSelectRow:(NSUInteger)row {
	[mediaItem startPlaybackAtChildIndex:row];
}

- (BOOL)canEditRow:(NSUInteger)row {
	return [mediaItem respondsToSelector:@selector(isEditable)] && [mediaItem isEditable];
}

- (void)deleteRow:(NSUInteger)row {
	updating = YES;
	[mediaItem deleteChildAtIndex:row];
	updating = NO;
}
										
- (void)moveRowAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
	updating = YES;
	[mediaItem moveChildFromIndex:fromIndex toIndex:toIndex];
	updating = NO;
}

- (void)object:(NSObject *)object wasSetFrom:(id)oldValue to:(id)newValue {
	[self.delegate reloadAllRowsOfSection:self];
}

- (void)objects:(NSArray *)objects wereInsertedAtIndexes:(NSIndexSet *)indexes ofObject:(NSObject *)object {
	if(updating) {
		return;
	}
	[self.delegate reloadAllRowsOfSection:self];
}

- (void)objects:(NSArray *)objects wereDeletedAtIndexes:(NSIndexSet *)indexes ofObject:(NSObject *)object {
	if(updating) {
		return;
	}
	[self.delegate reloadAllRowsOfSection:self];
}

- (void)objects:(NSArray *)oldObjects wereReplacedWithObjects:(NSArray *)newObjects atIndexes:(NSIndexSet *)indexes ofObject:(NSObject *)object {
	[self.delegate reloadAllRowsOfSection:self];
}


@end

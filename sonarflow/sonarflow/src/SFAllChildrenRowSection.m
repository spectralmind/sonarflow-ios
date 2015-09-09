#import "SFAllChildrenRowSection.h"

#import "SFMediaItem.h"
#import "SFArrayObserver.h"

static NSString * const kAllChildrenCellIdentifier = @"AllChildrenCell";

@interface SFAllChildrenRowSection () <SFArrayObserverDelegate>

@end

@implementation SFAllChildrenRowSection {
	@private
	NSObject<SFMediaItem> *mediaItem;
	SFArrayObserver *childrenObserver;
	NSString *allElementsTitle;
}

- (id)initWithMediaItem:(NSObject<SFMediaItem> *)theMediaItem allElementsTitle:(NSString *)theAllElementsTitle {
    self = [super init];
    if (self) {
		mediaItem = theMediaItem;
		childrenObserver = [[SFArrayObserver alloc] initWithObject:mediaItem keyPath:@"children" delegate:self];
		allElementsTitle = theAllElementsTitle;
    }
    return self;
}


@synthesize title;
@synthesize delegate;

- (NSUInteger)numberOfRows {
	return [self hasAllElementsRow] ? 1 : 0;
}

- (BOOL)hasAllElementsRow {
	return [mediaItem.children count] > 1;
}

- (CGFloat)heightForRow:(NSUInteger)row inTableView:(UITableView *)tableView {
	return tableView.rowHeight;
}

- (UITableViewCell *)cellForRow:(NSUInteger)row inTableView:(UITableView *)tableView {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAllChildrenCellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAllChildrenCellIdentifier];
    }
	[self configureAllElementsCell:cell];
	return cell;
}

- (void)configureAllElementsCell:(UITableViewCell *)cell {
	cell.textLabel.text = allElementsTitle;
	cell.detailTextLabel.text = nil;
	cell.imageView.image = nil;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (NSObject<SFMediaItem> *)mediaItemForRow:(NSUInteger)row {
	return [mediaItem allChildrenComposite];
}

- (BOOL)canSelectRow:(NSUInteger)row {
	return YES;
}

- (BOOL)hasDetailViewControllerForRow:(NSUInteger)row {
	return YES;
}

- (UIViewController *)detailViewControllerForRow:(NSUInteger)row factory:(MediaViewControllerFactory *)factory {
	return [[self mediaItemForRow:row] createDetailViewControllerWithFactory:factory];
}

- (void)handleSelectRow:(NSUInteger)row {
}

- (void)object:(NSObject *)object wasSetFrom:(id)oldValue to:(id)newValue {
	[self.delegate reloadAllRowsOfSection:self];
}

- (void)objects:(NSArray *)objects wereInsertedAtIndexes:(NSIndexSet *)indexes ofObject:(NSObject *)object {
	[self.delegate reloadAllRowsOfSection:self];
}

- (void)objects:(NSArray *)objects wereDeletedAtIndexes:(NSIndexSet *)indexes ofObject:(NSObject *)object {
	[self.delegate reloadAllRowsOfSection:self];
}

- (void)objects:(NSArray *)oldObjects wereReplacedWithObjects:(NSArray *)newObjects atIndexes:(NSIndexSet *)indexes ofObject:(NSObject *)object {
	[self.delegate reloadAllRowsOfSection:self];
}

@end

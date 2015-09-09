#import "SFSectionsTableViewController.h"

#import "UITableViewController+Popover.h"
#import "PlaylistPicker.h"
#import "SFMenuTarget.h"
#import "SFTableViewSection.h"

@interface SFSectionsTableViewController () <PlaylistEditorDelegate, MenuTargetDelegate, SFTableViewSectionDelegate>


@end

@implementation SFSectionsTableViewController {
	@private
	NSArray *sections;
	NSObject<PlaylistEditor> *playlistEditor;
	MediaViewControllerFactory *factory;
	
	BOOL ignoreNextTap;	
}

#pragma mark -
#pragma mark Initialization

- (id)initWithSections:(NSArray *)theSections playlistEditor:(NSObject<PlaylistEditor> *)thePlaylistEditor factory:(MediaViewControllerFactory *)theFactory {
	self = [super initWithStyle:UITableViewStylePlain];
	if(self) {
		sections = theSections;
		for(id<SFTableViewSection> section in sections) {
			section.delegate = self;
		}
		playlistEditor = thePlaylistEditor;
		factory = theFactory;
	}
	return self;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self updatePopoverSize];
}

- (void)updatePopoverSize {
	[self updatePopoverSizeWithMinHeight:[self minPopoverRows]];
}

- (NSUInteger)minPopoverRows {
	return 5;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
	
	[playlistEditor attachToView:self.tableView delegate:self];
	if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		playlistEditor.delegate = self;
	}
}

- (NSUInteger)numberOfRows {
	NSUInteger numRows = 0;
	for(id<SFTableViewSection> section in sections) {
		numRows += [section numberOfRows];
	}
	return numRows;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[playlistEditor detachFromView:self.tableView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// deprecated in iOS 6
	return YES;
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionIndex {
	id<SFTableViewSection> section = [sections objectAtIndex:sectionIndex];
	return [section title];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
	id<SFTableViewSection> section = [sections objectAtIndex:sectionIndex];
	return [section numberOfRows];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self canEditIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self canEditIndexPath:indexPath];
}

- (BOOL)canEditIndexPath:(NSIndexPath *)indexPath {
	if(self.isEditable == NO) {
		return NO;
	}
	
	id<SFTableViewSection> section = [sections objectAtIndex:indexPath.section];
	if([section respondsToSelector:@selector(canEditRow:)] == NO) {
		return NO;
	}

	return [section canEditRow:indexPath.row];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	if(proposedDestinationIndexPath.section == sourceIndexPath.section) {
		return proposedDestinationIndexPath;
	}
	
	if(proposedDestinationIndexPath.section < sourceIndexPath.section) {
		return [NSIndexPath indexPathForRow:0 inSection:sourceIndexPath.section];
	}
	else {
		id<SFTableViewSection> section = [sections objectAtIndex:sourceIndexPath.section];
		return [NSIndexPath indexPathForRow:[section numberOfRows] - 1 inSection:sourceIndexPath.section];
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSAssert([self canEditIndexPath:indexPath], @"Modified readonly row");
	
    if(editingStyle == UITableViewCellEditingStyleDelete) {
		id<SFTableViewSection> section = [sections objectAtIndex:indexPath.section];
		[section deleteRow:indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
	  toIndexPath:(NSIndexPath *)toIndexPath {
	NSAssert([self canEditIndexPath:fromIndexPath] && [self canEditIndexPath:toIndexPath], @"Modified readonly row");
	NSAssert(fromIndexPath.section == toIndexPath.section, @"Can not move rows between sections");
	id<SFTableViewSection> section = [sections objectAtIndex:fromIndexPath.section];

	[section moveRowAtIndex:fromIndexPath.row toIndex:toIndexPath.row];
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(ignoreNextTap) {
		ignoreNextTap = NO;
		return nil;
	}
	id<SFTableViewSection> section = [sections objectAtIndex:indexPath.section];
	if([section canSelectRow:indexPath.row] == NO) {
		return nil;
	}

	return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	id<SFTableViewSection> section = [sections objectAtIndex:indexPath.section];
	return [section heightForRow:indexPath.row inTableView:tableView];
}
	
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	id<SFTableViewSection> section = [sections objectAtIndex:indexPath.section];
	return [section cellForRow:indexPath.row inTableView:tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	id<SFTableViewSection> section = [sections objectAtIndex:indexPath.section];
	if([section hasDetailViewControllerForRow:indexPath.row]) {
		UIViewController *viewController = [section detailViewControllerForRow:indexPath.row factory:factory];
		[self.navigationController pushViewController:viewController animated:YES];
	}
	else {
		[section handleSelectRow:indexPath.row];
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

#pragma mark - PlaylistEditorDelegate

- (void)presentPlaylistPicker:(PlaylistPicker *)picker {
	[self presentModalViewController:picker animated:YES];
}

#pragma mark -  MenuTargetDelegate

- (SFMenuTarget *)menuTargetForLocation:(CGPoint)location {
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
	if(indexPath == nil) {
		return nil;
	}
	
	return [SFMenuTarget menuTargetWithMediaItem:[self mediaItemForIndexPath:indexPath]
									boundingRect:[self.tableView rectForRowAtIndexPath:indexPath]];
}

- (NSObject<SFMediaItem> *)mediaItemForIndexPath:(NSIndexPath *)indexPath {
	id<SFTableViewSection> section = [sections objectAtIndex:indexPath.section];
	return [section mediaItemForRow:indexPath.row];
}

- (void)didShowMenuAtLocation:(CGPoint)location inView:(UIView *)view {
	ignoreNextTap = YES;
}

- (void)willHideMenu {
}

- (void)didSelectMenuItem {
	ignoreNextTap = NO;
}

#pragma mark - SFTableViewSectionDelegate

- (void)reloadAllRowsOfSection:(id<SFTableViewSection>)section {
	// Reloading more than one section with "reloadSections:withRowAnimation:" in one iteration causes a crash in UITableView (on iOS 5.1.1)
	// Therefore, we have to reload the whole table
	[self.tableView reloadData];
	[self updatePopoverSize];
	//	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[self indexOfSection:section]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)reloadRows:(NSIndexSet *)rowIndexes ofSection:(id<SFTableViewSection>)section {
	NSArray *indexPaths = [self indexPathsForRows:rowIndexes ofSection:section];
	[self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (void)removeRows:(NSIndexSet *)rowIndexes fromSection:(id<SFTableViewSection>)section {
	NSArray *indexPaths = [self indexPathsForRows:rowIndexes ofSection:section];
	[self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}
- (void)insertRows:(NSIndexSet *)rowIndexes intoSection:(id<SFTableViewSection>)section {
	NSArray *indexPaths = [self indexPathsForRows:rowIndexes ofSection:section];
	[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
	// "updatePopoverSize" must happen AFTER the table view update because "updatePopoverSize" causes the table view to refresh again.
	[self updatePopoverSize];
}

- (NSArray *)indexPathsForRows:(NSIndexSet *)rowIndexes ofSection:(id<SFTableViewSection>)section {
	NSUInteger sectionIndex = [self indexOfSection:section];
	NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:[rowIndexes count]];
	[rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		[indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:sectionIndex]];
	}];
	return indexPaths;
}

- (NSUInteger)indexOfSection:(id<SFTableViewSection>)section {
	return [sections indexOfObject:section];
}

- (void)toggleEditing {
	NSAssert(self.editable, @"Toggling editing for non-editable SFSectionsTableViewController");
	[self setEditing:!self.editing animated:YES];
}

- (void)popViewControllerAnimated:(BOOL)animated {
	[self.navigationController popViewControllerAnimated:animated];
}

@end

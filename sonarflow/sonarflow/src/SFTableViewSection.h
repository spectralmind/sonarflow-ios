#import <Foundation/Foundation.h>

@protocol SFMediaItem;
@protocol SFTableViewSectionDelegate;
@class MediaViewControllerFactory;

@protocol SFTableViewSection <NSObject>

@property (nonatomic, weak) id<SFTableViewSectionDelegate> delegate;
@property (nonatomic, strong) NSString *title;

- (NSUInteger)numberOfRows;
- (CGFloat)heightForRow:(NSUInteger)row inTableView:(UITableView *)tableView;
- (UITableViewCell *)cellForRow:(NSUInteger)row inTableView:(UITableView *)tableView;

- (NSObject<SFMediaItem> *)mediaItemForRow:(NSUInteger)row;
- (BOOL)canSelectRow:(NSUInteger)row;
- (BOOL)hasDetailViewControllerForRow:(NSUInteger)row;
- (UIViewController *)detailViewControllerForRow:(NSUInteger)row factory:(MediaViewControllerFactory *)factory;
- (void)handleSelectRow:(NSUInteger)row;

@optional
- (BOOL)canEditRow:(NSUInteger)row;
- (void)deleteRow:(NSUInteger)row;
- (void)moveRowAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end

@protocol SFTableViewSectionDelegate <NSObject>

- (void)reloadAllRowsOfSection:(id<SFTableViewSection>)section;
- (void)reloadRows:(NSIndexSet *)rowIndexes ofSection:(id<SFTableViewSection>)section;
- (void)removeRows:(NSIndexSet *)rowIndexes fromSection:(id<SFTableViewSection>)section;
- (void)insertRows:(NSIndexSet *)rowIndexes intoSection:(id<SFTableViewSection>)section;

- (BOOL)isEditing;
- (void)toggleEditing;
- (UITableView *)tableView;
- (void)popViewControllerAnimated:(BOOL)animated;

@end
#import <UIKit/UIKit.h>

#import "PlaylistEditor.h"
#import "CollectionMenuController.h"
#import "MediaViewControllerFactory.h"

@interface SFSectionsTableViewController : UITableViewController

- (id)initWithSections:(NSArray *)theSections playlistEditor:(NSObject<PlaylistEditor> *)thePlaylistEditor factory:(MediaViewControllerFactory *)theFactory;

@property (nonatomic, assign, getter = isEditable) BOOL editable;

//Pure virtual
- (NSUInteger)numberOfRows;
- (NSObject<SFMediaItem> *)mediaItemForIndexPath:(NSIndexPath *)indexPath;


@end

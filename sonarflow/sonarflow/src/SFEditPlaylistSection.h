#import <Foundation/Foundation.h>

#import "SFTableViewSection.h"

@protocol SFPlaylist;

@interface SFEditPlaylistSection : NSObject <SFTableViewSection>

- (id)initWithPlaylist:(NSObject<SFPlaylist> *)thePlaylist;

@property (nonatomic, strong) IBOutlet UITableViewCell *normalHeaderCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *editingHeaderCell;

- (IBAction)toggleEdit;
- (IBAction)confirmClearPlaylist;
- (IBAction)confirmDeletePlaylist;


@end

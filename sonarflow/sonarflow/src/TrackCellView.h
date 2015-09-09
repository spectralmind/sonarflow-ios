#import "SFAbstractTrackCellView.h"

@interface TrackCellView : SFAbstractTrackCellView

+ (TrackCellView *)trackCellForTableView:(UITableView *)tableView;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (void)setTrackNumber:(NSNumber *)trackNumber;

@end

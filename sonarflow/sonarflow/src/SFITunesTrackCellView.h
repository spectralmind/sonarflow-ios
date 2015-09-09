#import "SFAbstractTrackCellView.h"

@class ImageFactory;

@interface SFITunesTrackCellView : SFAbstractTrackCellView

+ (SFITunesTrackCellView *)trackCellForTableView:(UITableView *)tableView withBuyUrl:(NSURL *)buyUrl imageFactory:(ImageFactory *)imageFactory;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier buyUrl:(NSURL *)theBuyUrl imageFactory:(ImageFactory *)theImageFactory;


@end

#import "SFAbstractTrackCellView.h"

@class ImageFactory;

typedef void (^SetStarredBlock)(BOOL starred);

@interface SFSpotifyTrackCellView : SFAbstractTrackCellView

@property (nonatomic, copy) SetStarredBlock setStarredBlock;
@property (nonatomic, assign) BOOL starred;

+ (SFSpotifyTrackCellView *)trackCellForTableView:(UITableView *)tableView withImageFactory:(ImageFactory *)imageFactory;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier imageFactory:(ImageFactory *)theImageFactory;


@end

#import <UIKit/UIKit.h>

@protocol SFMediaItem;

@interface TrackTitleView : UIView
@property (nonatomic, weak) IBOutlet UILabel *titleView;
@property (nonatomic, weak) IBOutlet UILabel *subtitleView;

- (void)showInformationForMediaItem:(id<SFMediaItem>)mediaItem;

@end

#import <UIKit/UIKit.h>

#import "InfoIpadViewTitleView.h"

@protocol OverlayCloseRequestDelegate;

@interface SFIPadHelpViewController : UIViewController

@property (nonatomic, weak) IBOutlet InfoIpadViewTitleView *titleView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) id<OverlayCloseRequestDelegate> closeRequestDelegate;
@property (nonatomic, weak) IBOutlet UIScrollView *howtoScrollView;
@property (nonatomic, weak) IBOutlet UIView *howtoView;
@property (nonatomic, weak) IBOutlet UIScrollView *socialScrollView;
@property (nonatomic, weak) IBOutlet UIView *socialView;
@property (nonatomic, weak) IBOutlet UIScrollView *contactScrollView;
@property (nonatomic, weak) IBOutlet UIView *contactView;
@property (nonatomic, weak) IBOutlet UITableViewCell *lastfmAccountCell;
@property (nonatomic, weak) IBOutlet UIButton *lastfmSettingsButton;

@property (nonatomic, weak) IBOutlet UILabel *versionLabel;

- (void)scrollToPartners;

@end

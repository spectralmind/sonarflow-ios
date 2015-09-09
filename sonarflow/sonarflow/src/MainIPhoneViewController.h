#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MessageUI/MessageUI.h>

#import "MainViewController.h"

@protocol SFIPhoneHelpView;
@class ImageSubmitter;
@class TipView;

@interface MainIPhoneViewController : MainViewController

@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIButton *pauseButton;
@property (nonatomic, weak) IBOutlet UIButton *standaloneHomeButton;
@property (nonatomic, weak) IBOutlet UIButton *standalonePlaylistsButton;

@property (nonatomic, weak) IBOutlet UIView *header;
@property (nonatomic, weak) IBOutlet UIView *footer;
@property (nonatomic, weak) IBOutlet UIImageView *footerBackgroundView;

@property (nonatomic, weak) IBOutlet UIView *timelineView;

@property (nonatomic, strong) IBOutlet UIView<SFIPhoneHelpView> *helpView;

@end

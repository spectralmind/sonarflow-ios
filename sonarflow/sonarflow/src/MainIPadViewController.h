#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>
#import <MediaPlayer/MediaPlayer.h>

#import "SFIPadHelpViewController.h"
#import "MainViewController.h"

@interface MainIPadViewController : MainViewController
		<UIPopoverControllerDelegate> 

@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UIButton *playlistBarButton;
@property (nonatomic, weak) IBOutlet UIButton *playPauseButton;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *subtitleLabel;

@property (nonatomic, weak) IBOutlet UIView *headerInsetView;
@property (nonatomic, weak) IBOutlet UIImageView *headerInsetImageView;
@property (nonatomic, weak) IBOutlet UIView *headerVolumeView;
@property (nonatomic, weak) IBOutlet UIImageView *sonarflowLogo;

@end

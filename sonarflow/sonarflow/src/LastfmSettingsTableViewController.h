#import <UIKit/UIKit.h>

#import "LastfmSettingsViewControllerDelegate.h"

@class LastfmSettings;
@class LoginStatusView;

@interface LastfmSettingsTableViewController : UITableViewController

@property (nonatomic, weak) id<LastfmSettingsViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UITableViewCell *usernameCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *passwordCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *scrobbleCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *createAccountCell;
@property (weak, nonatomic) IBOutlet UISwitch *scrobbleSwitch;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet LoginStatusView *loginStatusView;

- (IBAction)handleScrobbleSwitchChanged:(UISwitch *)sender;
- (IBAction)handleUsernameChanged:(UITextField *)sender;
- (IBAction)handlePasswordChanged:(UITextField *)sender;
- (IBAction)handleDoneTapped:(UIBarButtonItem *)sender;
- (IBAction)handleCancelTapped:(UIBarButtonItem *)sender;

- (void)resetWithSettings:(LastfmSettings *)settings;

@end

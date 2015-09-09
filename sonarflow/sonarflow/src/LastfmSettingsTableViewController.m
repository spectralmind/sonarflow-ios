#import "LastfmSettingsTableViewController.h"

#import "LastfmSettings.h"
#import "LoginStatusView.h"

@interface LastfmSettingsTableViewController ()

@property (nonatomic, strong) LastfmSettings *originalSettings;
@property (nonatomic, copy) LastfmSettings *currentSettings;

@end

@implementation LastfmSettingsTableViewController {
	BOOL hasChangedLogin;
	LastfmLoginCompletionBlock completionBlock;
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
		[self createCompletionBlock];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		[self createCompletionBlock];
    }
    return self;
}


- (void)createCompletionBlock {
	__weak LastfmSettingsTableViewController *controller = self;
	completionBlock = [^(BOOL success) {
		if(success) {
			[controller acceptLogin];
		}
		else {
			[controller rejectLogin];
		}
	} copy];
}

- (void)acceptLogin {
	[self.delegate finishedWithLastfmSettings:self.currentSettings];
}

- (void)rejectLogin {
	self.loginStatusView.state = LoginStatusViewStateError;
	[self enableControls:YES];
}

- (void)viewDidLoad {
	self.navigationItem.title = @"last.fm Settings";
	self.navigationItem.leftBarButtonItem = self.cancelButton;
	self.navigationItem.rightBarButtonItem = self.doneButton;
	self.loginStatusView.defaultText = @"Please provide your last.fm account details.";
	[self updateViewFromSettings:self.currentSettings];
}

- (void)viewDidUnload {
    [self setUsernameCell:nil];
    [self setPasswordCell:nil];
    [self setScrobbleCell:nil];
	[self setScrobbleSwitch:nil];
	[self setUsernameTextField:nil];
	[self setPasswordTextField:nil];
	[self setDoneButton:nil];
	[self setCancelButton:nil];

    [self setCreateAccountCell:nil];
	[self setLoginStatusView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// deprecated in iOS 6
	return YES;
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

- (void)resetWithSettings:(LastfmSettings *)settings {
	self.originalSettings = settings;
	self.currentSettings = self.originalSettings;
	self.loginStatusView.state = LoginStatusViewStateDefault;
	[self updateViewFromSettings:self.currentSettings];
}

- (void)updateViewFromSettings:(LastfmSettings *)settings {
	[self.scrobbleSwitch setOn:settings.scrobble];
	self.usernameTextField.text = settings.username;
	self.passwordTextField.text = settings.password;
	hasChangedLogin = NO;
	
	[self enableControls:YES];
	[self.tableView reloadData];
}

- (void)enableControls:(BOOL)enable {
	[self.scrobbleSwitch setEnabled:enable];
	[self.usernameTextField setEnabled:enable];
	[self.passwordTextField setEnabled:enable];
	[self.doneButton setEnabled:enable];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if(self.currentSettings.scrobble) {
		return 3;
	}
	else {
		return 1;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch(section) {
		case 0:
			return @"Settings";
		case 1:
			return @"Account information";
		case 2:
			return nil;
		default:
			NSAssert(0, @"Unexpected section");
			return nil;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch(section) {
		case 0:
			return 1;
		case 1:
			return 2;
		case 2:
			return 1;
		default:
			NSAssert(0, @"Unexpected section");
			return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch(indexPath.section) {
		case 0:
			NSAssert(indexPath.row == 0, @"Unexpected indexPath");
			return self.scrobbleCell;
		case 1:
			return [self accountCellForRow:indexPath.row];
		case 2:
			return self.createAccountCell;
		default:
			NSAssert(0, @"Unexpected section");
			return nil;
	}
}
	   
- (UITableViewCell *)accountCellForRow:(NSUInteger)row {
	switch(row) {
		case 0:
			return self.usernameCell;
		case 1:
			return self.passwordCell;
		default:
			NSAssert(0, @"Unexpected indexPath");
			return nil;
	}
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if(section == 1) {
		return self.loginStatusView;
	}
	
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if(section == 1) {
		return CGRectGetHeight(self.loginStatusView.bounds);
	}
	
	return 0.0f;
}


#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if([self isCreateAccountIndexPath:indexPath]) {
		return indexPath;
	}
	
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if([self isCreateAccountIndexPath:indexPath]) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		[self.delegate createNewLastfmAccount];
		return;
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (BOOL)isCreateAccountIndexPath:(NSIndexPath *)indexPath {
	return indexPath.section == 2 && indexPath.row == 0;
}

- (IBAction)handleScrobbleSwitchChanged:(UISwitch *)sender {
	if(self.currentSettings.scrobble == [sender isOn]) {
		return;
	}
	
	self.currentSettings.scrobble = [sender isOn];
	if(self.currentSettings.scrobble) {
		[self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationTop];
	}
	else {
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationTop];
	}
}

- (IBAction)handleUsernameChanged:(UITextField *)sender {
	self.currentSettings.username = sender.text;
	hasChangedLogin = YES;
}

- (IBAction)handlePasswordChanged:(UITextField *)sender {
	self.currentSettings.password = sender.text;
	hasChangedLogin = YES;
}

- (IBAction)handleDoneTapped:(UIBarButtonItem *)sender {
	[self finishTextInput];
	
	if(self.currentSettings.scrobble == NO) {
		[self resetLoginFromOriginalSettings];
	}
	
	if(hasChangedLogin || [self hasEnabledScrobble]) {
		[self enableControls:NO];
		self.loginStatusView.state = LoginStatusViewStateVerifying;
		[self.delegate verifyLastfmLoginWithUsername:self.currentSettings.username password:self.currentSettings.password completion:completionBlock];
	}
	else {
		[self.delegate finishedWithLastfmSettings:self.currentSettings];
	}
}

- (void)finishTextInput {
	if([self.usernameTextField isFirstResponder]) {
		[self.usernameTextField resignFirstResponder];
	}
	if([self.passwordTextField isFirstResponder]) {
		[self.passwordTextField resignFirstResponder];
	}
}

- (void)resetLoginFromOriginalSettings {
	self.currentSettings.username = self.originalSettings.username;
	self.currentSettings.password = self.originalSettings.password;
	hasChangedLogin = NO;
}

- (BOOL)hasEnabledScrobble {
	return self.originalSettings.scrobble == NO &&
	self.currentSettings.scrobble == YES;
}

- (IBAction)handleCancelTapped:(UIBarButtonItem *)sender {
	[self.delegate didCancelLastfmSettings];
}


@end

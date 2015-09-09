#import "LastfmSettingsTableViewControllerTests.h"

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMock/OCMock.h>
#import "LastfmSettingsTableViewController.h"
#import "LastfmSettings.h"
#import "LastfmSettingsViewControllerDelegate.h"
#import "LoginStatusView.h"

typedef BOOL(^ArgCheckerBlock)(id);

@interface TestableLastfmSettingsTableViewController : LastfmSettingsTableViewController

@end

@implementation TestableLastfmSettingsTableViewController {
	@private
	UITableView *tableView;
}

- (void)setTableView:(UITableView *)newTableView {
	if(tableView == newTableView) {
		return;
	}
	
	tableView = newTableView;
}

- (UITableView *)tableView {
	return tableView;
}

@end

@implementation LastfmSettingsTableViewControllerTests {
	LastfmSettingsTableViewController *sut;
	id usernameTextFieldMock;
	id passwordTextFieldMock;
	id scrobbleSwitchMock;
	id delegateMock;
	id tableViewMock;
	id doneButtonMock;
	id loginStatusViewMock;
	
	ArgCheckerBlock completionBlockCapturer;
	LastfmLoginCompletionBlock completionBlock;
}

- (void)setUp {
	usernameTextFieldMock = [OCMockObject niceMockForClass:[UITextField class]];
	passwordTextFieldMock = [OCMockObject niceMockForClass:[UITextField class]];
	scrobbleSwitchMock = [OCMockObject niceMockForClass:[UISwitch class]];
	delegateMock = [OCMockObject mockForProtocol:@protocol(LastfmSettingsViewControllerDelegate)];
	tableViewMock = [OCMockObject niceMockForClass:[UITableView class]];
	doneButtonMock = [OCMockObject niceMockForClass:[UIBarButtonItem class]];
	loginStatusViewMock = [OCMockObject niceMockForClass:[LoginStatusView class]];
	
	sut = [[TestableLastfmSettingsTableViewController alloc] init];
	sut.usernameTextField = usernameTextFieldMock;
	sut.passwordTextField = passwordTextFieldMock;
	sut.scrobbleSwitch = scrobbleSwitchMock;
	sut.delegate = delegateMock;
	sut.tableView = tableViewMock;
	sut.doneButton = doneButtonMock;
	sut.loginStatusView = loginStatusViewMock;
	
	completionBlock = nil;
	
	completionBlockCapturer = [^(id value) {
		completionBlock = [value copy];
		return YES;
	} copy];
}

- (LastfmSettings *)settingsWithUsername:(NSString *)username password:(NSString *)password {
	return [LastfmSettings settingsWithScrobble:NO username:username password:password];
}

- (LastfmSettings *)settingsWithScrobble:(BOOL)scrobble {
	return [LastfmSettings settingsWithScrobble:scrobble username:@"Something" password:@"Irrelevant"];
}

- (void)verifyMocks {
	[usernameTextFieldMock verify];
	[passwordTextFieldMock verify];
	[scrobbleSwitchMock verify];
	[delegateMock verify];
	[tableViewMock verify];
	[doneButtonMock verify];
	[loginStatusViewMock verify];
}

- (void)verifyNumberOfSections:(NSInteger)numExpectedSections {
	STAssertEquals(numExpectedSections, [sut numberOfSectionsInTableView:nil], @"Unexpected number of sections");
}

- (void)expectControlsEnabled:(BOOL)enabled {
	[[scrobbleSwitchMock expect] setEnabled:enabled];
	[[usernameTextFieldMock expect] setEnabled:enabled];
	[[passwordTextFieldMock expect] setEnabled:enabled];
	[[doneButtonMock expect] setEnabled:enabled];
}

- (void)expectValuesSetFromSettings:(LastfmSettings *)settings {
	[[scrobbleSwitchMock expect] setOn:settings.scrobble];
	[[usernameTextFieldMock expect] setText:settings.username];
	[[passwordTextFieldMock expect] setText:settings.password];
}

- (void)expectShowLoginSection {
	[[tableViewMock expect] insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationTop];
}

- (void)expectHideLoginSection {
	[[tableViewMock expect] deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationTop];
}

- (void)changeScrobbleSwitchToValue:(BOOL)newValue {
	[[[scrobbleSwitchMock stub] andReturnValue:[NSNumber numberWithBool:newValue]] isOn];
	[sut handleScrobbleSwitchChanged:scrobbleSwitchMock];
}

- (void)changeUsernameTextFieldToText:(NSString *)newText {
	[[[usernameTextFieldMock stub] andReturn:newText] text];
	[sut handleUsernameChanged:usernameTextFieldMock];
}

- (void)changePasswordTextFieldToText:(NSString *)newText {
	[[[passwordTextFieldMock stub] andReturn:newText] text];
	[sut handlePasswordChanged:passwordTextFieldMock];
}

- (void)testPropertiesNotNil {
	assertThat(sut.usernameTextField, isNot(nilValue()));
	assertThat(sut.passwordTextField, isNot(nilValue()));
	assertThat(sut.scrobbleSwitch, isNot(nilValue()));
	assertThat(sut.delegate, isNot(nilValue()));
	assertThat(sut.tableView, isNot(nilValue()));
	assertThat(sut.doneButton, isNot(nilValue()));
	assertThat(sut.loginStatusView, isNot(nilValue()));
}

- (void)testInit {
	[[loginStatusViewMock expect] setDefaultText:(id)isNot(equalTo(@""))];
	
	[sut viewDidLoad];

	[self verifyNumberOfSections:1];
	[self verifyMocks];
	assertThat([sut tableView:tableViewMock viewForFooterInSection:1], equalTo(loginStatusViewMock));
}

- (void)testResetWithScrobbleDisabled {
	LastfmSettings *settings = [self settingsWithUsername:@"Hinz" password:@"Foo"];
	settings.scrobble = NO;
	[self expectValuesSetFromSettings:settings];
	[self expectControlsEnabled:YES];
	[[tableViewMock expect] reloadData];
	[[loginStatusViewMock expect] setState:LoginStatusViewStateDefault];
	
	[sut resetWithSettings:settings];
	
	[self verifyMocks];
	[self verifyNumberOfSections:1];
}

- (void)testResetWithScrobbleEnabled {
	LastfmSettings *settings = [self settingsWithUsername:@"Hinz" password:@"Foo"];
	settings.scrobble = YES;
	[self expectValuesSetFromSettings:settings];
	[self expectControlsEnabled:YES];
	[[tableViewMock expect] reloadData];
	[[loginStatusViewMock expect] setState:LoginStatusViewStateDefault];
	
	[sut resetWithSettings:settings];
	
	[self verifyMocks];
	[self verifyNumberOfSections:3];
}

- (void)testChangeScrobbleToOn {
	[sut resetWithSettings:[self settingsWithScrobble:NO]];
	
	[self expectShowLoginSection];
	[self changeScrobbleSwitchToValue:YES];
	
	[self verifyMocks];
	[self verifyNumberOfSections:3];
}

- (void)testChangeScrobbleToOff {
	[sut resetWithSettings:[self settingsWithScrobble:YES]];

	[self expectHideLoginSection];
	[self changeScrobbleSwitchToValue:NO];
	
	[self verifyMocks];
	[self verifyNumberOfSections:1];
}

- (void)testTryFinishWithoutChanges {
	[sut resetWithSettings:[self settingsWithScrobble:YES]];
	
	[[delegateMock expect] finishedWithLastfmSettings:[self settingsWithScrobble:YES]];
	[sut handleDoneTapped:doneButtonMock];
	
	[self verifyMocks];	
}

- (void)testTryFinishWithDisabledScrobbleAfterUsernameChange {
	[sut resetWithSettings:[self settingsWithScrobble:YES]];
	
	[self changeUsernameTextFieldToText:@"SomeChangedValue"];
	[self changeScrobbleSwitchToValue:NO];
	[[delegateMock expect] finishedWithLastfmSettings:[self settingsWithScrobble:NO]];
	[sut handleDoneTapped:doneButtonMock];
	
	[self verifyMocks];	
}

- (void)testTryFinishWithDisabledScrobbleAfterPasswordChange {
	[sut resetWithSettings:[self settingsWithScrobble:YES]];
	
	[self changePasswordTextFieldToText:@"SomeChangedValue"];
	[self changeScrobbleSwitchToValue:NO];
	[[delegateMock expect] finishedWithLastfmSettings:[self settingsWithScrobble:NO]];
	[sut handleDoneTapped:doneButtonMock];
	
	[self verifyMocks];
}

- (void)testTryFinishAfterUsernameChange {
	LastfmSettings *settings = [self settingsWithScrobble:YES];
	[sut resetWithSettings:settings];
	NSString *newUsername = @"Event cooler name";
	[self changeUsernameTextFieldToText:newUsername];
	
	[[loginStatusViewMock expect] setState:LoginStatusViewStateVerifying];
	[[delegateMock expect] verifyLastfmLoginWithUsername:newUsername password:settings.password completion:OCMOCK_ANY];
	[self expectControlsEnabled:NO];
	[sut handleDoneTapped:doneButtonMock];
	
	[self verifyMocks];
}

- (void)testTryFinishAfterPasswordChange {
	LastfmSettings *settings = [self settingsWithScrobble:YES];
	[sut resetWithSettings:settings];
	NSString *newPassword = @"Even more secret";
	[self changePasswordTextFieldToText:newPassword];
	
	[[loginStatusViewMock expect] setState:LoginStatusViewStateVerifying];
	[[delegateMock expect] verifyLastfmLoginWithUsername:settings.username password:newPassword completion:OCMOCK_ANY];
	[self expectControlsEnabled:NO];
	[sut handleDoneTapped:doneButtonMock];
	
	[self verifyMocks];
}

- (void)testTryFinishAfterScrobbleEnabled {
	LastfmSettings *settings = [self settingsWithScrobble:NO];
	[sut resetWithSettings:settings];
	[self changeScrobbleSwitchToValue:YES];
	
	[[loginStatusViewMock expect] setState:LoginStatusViewStateVerifying];
	[[delegateMock expect] verifyLastfmLoginWithUsername:settings.username password:settings.password completion:OCMOCK_ANY];
	[self expectControlsEnabled:NO];
	[sut handleDoneTapped:doneButtonMock];
	
	[self verifyMocks];
}

- (void)testTryFinishVerificationFailed {
	LastfmSettings *settings = [self settingsWithScrobble:YES];
	[sut resetWithSettings:settings];
	NSString *newPassword = @"Even more secret";
	[self changePasswordTextFieldToText:newPassword];

	[[loginStatusViewMock expect] setState:LoginStatusViewStateVerifying];
	[[delegateMock expect] verifyLastfmLoginWithUsername:settings.username password:newPassword completion:[OCMArg checkWithBlock:completionBlockCapturer]];
	[sut handleDoneTapped:doneButtonMock];

	[[loginStatusViewMock expect] setState:LoginStatusViewStateError];
	[self expectControlsEnabled:YES];
	
	assertThat(completionBlock, isNot(nilValue()));
	if (completionBlock != nil) {
		completionBlock(NO);
	}
	
	[self verifyMocks];
}

- (void)testTryFinishVerificationSuccessful {
	LastfmSettings *settings = [self settingsWithScrobble:YES];
	[sut resetWithSettings:settings];
	NSString *newPassword = @"Even more secret";
	[self changePasswordTextFieldToText:newPassword];

	[[loginStatusViewMock expect] setState:LoginStatusViewStateVerifying];
	[[delegateMock expect] verifyLastfmLoginWithUsername:settings.username password:newPassword completion:[OCMArg checkWithBlock:completionBlockCapturer]];
	[sut handleDoneTapped:doneButtonMock];

	[[delegateMock expect] finishedWithLastfmSettings:[LastfmSettings settingsWithScrobble:YES username:settings.username password:newPassword]];

	assertThat(completionBlock, isNot(nilValue()));
	if (completionBlock != nil) {
		completionBlock(YES);
	}

	[self verifyMocks];
}

@end

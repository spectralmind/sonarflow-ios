#import "ArtistInfoViewController.h"
#import "ArtistInfoViewController+Private.h"

#import "ArtistSharingDelegate.h"
#import "SFSmartistFactory.h"
#import "SMArtist.h"
#import "Notifications.h"

@interface ArtistInfoViewController () <SMArtistDelegate>

@property (nonatomic, strong) SMArtist *smartist;

@property (nonatomic, strong) NSString *biographyText;
@property (nonatomic, strong) NSString *biographyURL;

@property (nonatomic, strong) NSArray *artistImages; //containing SMArtistImage objects
@property (nonatomic, strong) NSArray *artistVideos; //containing SMArtistVideo objects

@property (nonatomic, strong) NSString *noBio;
@property (nonatomic, strong) NSString *noImages;
@property (nonatomic, strong) NSString *noVideos;

@end


@implementation ArtistInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)loadView
{
	[self doesNotRecognizeSelector:_cmd];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationItem.title = self.artistName;
}

- (void)viewWillAppear:(BOOL)animated
{
	BOOL update = self.updateWhenViewAppearsNextTime;
	[super viewWillAppear:animated];
	
	if (update) {
		[self updateContents];
	}
}

- (void)updateContents {
	
	if(self.artistName == nil) {
		return;
	}
	
	self.biographyText = nil;
	self.artistImages = nil;
	self.artistVideos = nil;
	
	self.noBio = nil;
	self.noImages = nil;
	self.noVideos = nil;

	[self.smartist getArtistBiosWithArtistName:self.artistName clientId:self.artistName priority:YES];
//	[self.smartist getArtistImagesWithArtistName:self.artistName withClientId:self.artistName];
	[self.smartist getArtistVideosWithArtistName:self.artistName clientId:self.artistName priority:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	self.updateWhenViewAppearsNextTime = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// deprecated in iOS 6
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Public Methods

- (void)useSmartistInstanceFromFactory:(SFSmartistFactory *)factory {
	SMArtist *smart = [factory newSmartistWithDelegate:self];
	self.smartist = smart;
}


#pragma mark - Private Methods

- (void)postStopYoutubePlaybackNotification {
	[[NSNotificationCenter defaultCenter] postNotificationName:SFStopYoutubeNotification object:self userInfo:nil];
}

- (void)parseAndSetBioFromBiosResult:(SMArtistBiosResult *)biosResult {
	if ([biosResult.bios count] == 0) {
		self.noBio = @"We are sorry, no biography is available.";
		return;
	}
	
	SMArtistBio *selectedBio = nil;
	for (SMArtistBio *bio in biosResult.bios) {
		if (bio.fulltext != nil) {
			selectedBio = bio;
			break;
		}
	}
	
	if (selectedBio == nil) {
		selectedBio = [biosResult.bios lastObject];
	}
	
	self.biographyURL = selectedBio.url;	
	self.biographyText = selectedBio.fulltext ? selectedBio.fulltext : selectedBio.previewText;
}

#pragma mark - SMArtistDelegate

- (void)doneWebRequestWithArtistBiosResult:(SMArtistBiosResult *)theResult {
	if([theResult.clientId isEqual:self.artistName] == NO) {
		return;
	}

	if (theResult.error != nil) {
		NSLog(@"ignoring erroneous SMArtistBiosResult: %@",[theResult.error description]);
		if (theResult.error.code == -1009) {
			self.noBio = @"The Internet connection appears to be offline.";
		}
		return;
	}
	//NSLog(@"doneWebRequestWithArtistBiosResult %@",theResult);
	[self parseAndSetBioFromBiosResult:theResult];
	
	/* don't just update the title without some sort of animation
	if ([self.artistName compare:theResult.recognizedArtistName] != NSOrderedSame) {
		self.artistName = theResult.recognizedArtistName;
	}
	 */
}

- (void)doneWebRequestWithArtistImagesResult:(SMArtistImagesResult *)theResult {
	if([theResult.clientId isEqual:self.artistName] == NO) {
		return;
	}
	
	if (theResult.error != nil) {
		NSLog(@"ignoring erroneous SMArtistImagesResult: %@",[theResult.error description]);
		if (theResult.error.code == -1009) {
			self.noImages = @"The Internet connection appears to be offline.";
		}
		return;
	}
	//NSLog(@"doneWebRequestWithArtistImagesResult %@",theResult);
	
	if ([theResult.images count] == 0) {
		self.noImages = @"We are sorry, no images are available.";
		return;
	}

	self.artistImages = theResult.images;
}

- (void)doneWebRequestWithArtistVideosResult:(SMArtistVideosResult *)theResult {
	if([theResult.clientId isEqual:self.artistName] == NO) {
		return;
	}
	
	if (theResult.error != nil) {
		NSLog(@"ignoring erroneous SMArtistImagesResult: %@",[theResult.error description]);
		if (theResult.error.code == -1009) {
			self.noVideos = @"The Internet connection appears to be offline.";
		}
		return;
	}
	//NSLog(@"doneWebRequestWithArtistVideosResult %@",theResult);
	
	if ([theResult.videos count] == 0) {
		self.noVideos = @"We are sorry, no videos are available.";
		return;
	}
	
	self.artistVideos = theResult.videos;
}


#pragma mark - YoutubeQueryDelegate

- (void)didFinishQueryWithUrls:(NSArray *)urlStringArray
{
	self.artistVideos = urlStringArray;
}

#pragma mark - Sharing

@synthesize facebookButton = _facebookButton;
- (UIButton *)facebookButton {
	if(_facebookButton != nil) {
		return _facebookButton;
	}
	
	UIImage *facebookIcon = [UIImage imageNamed:@"icon_shareFacebook"];
	_facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_facebookButton setBackgroundImage:facebookIcon forState:UIControlStateNormal];
	CGRect frame = CGRectZero;
	frame.size = facebookIcon.size;
	_facebookButton.frame = frame;
	[_facebookButton addTarget:self action:@selector(handleFacebookButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

	return _facebookButton;
}

@synthesize twitterButton = _twitterButton;
- (UIButton *)twitterButton {
	if(_twitterButton != nil) {
		return _twitterButton;
	}
	
	UIImage *twitterIcon = [UIImage imageNamed:@"icon_shareTwitter"];
	_twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_twitterButton setBackgroundImage:twitterIcon forState:UIControlStateNormal];
	CGRect frame = CGRectZero;
	frame.size = twitterIcon.size;
	_twitterButton.frame = frame;

	[_twitterButton addTarget:self action:@selector(handleTwitterButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	
	return _twitterButton;
}


- (void)handleFacebookButtonTapped:(UIButton *)sender {
	[self.sharingDelegate shareArtistOnFacebook:self.artistName];
}

- (void)handleTwitterButtonTapped:(UIButton *)sender {
	[self.sharingDelegate shareArtistOnTwitter:self.artistName];
}

@end

#import "ImageSubmitter.h"

#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

#import "Reachability.h"
#import "SFAppIdentity.h"

#define kMaxImageUploadTrials 4

@interface ImageSubmitter ()

@property (nonatomic, strong) UIImage *pendingImage;
@property (nonatomic, strong) NSString *pendingText;
@property (nonatomic, strong) NSString *pendingTrackTitle;
@property (nonatomic, strong) NSString *pendingArtist;
@property (nonatomic, strong) NSString *pendingAlbum;
@property (nonatomic, strong) NSString *pendingImageUrl;
@property (nonatomic, strong) NSString *pendingImageLink;

@end

@implementation ImageSubmitter {
	@private
	AppStatusObserver *statusObserver;
	
	SFAppIdentity *appIdentity;
    Facebook *facebook;
	
	id<ImageSubmitterDelegate> __weak delegate;
	
	UIImage *pendingImage;
	NSString *pendingText;
	NSString *pendingTrackTitle;
	NSString *pendingArtist;
	NSString *pendingAlbum;
	NSString *pendingImageUrl;
	NSString *pendingImageLink;
	
	ImageUploader *uploader;
	
	NSString *tradedoublerProgramID;
	NSString *tradedoublerWebsiteID;
	
	WebService webservice;
	NSUInteger uploadTrials;
}

@synthesize delegate;
@synthesize tradedoublerProgramID;
@synthesize tradedoublerWebsiteID;
@synthesize pendingImage;
@synthesize pendingText;
@synthesize pendingTrackTitle;
@synthesize pendingArtist;
@synthesize pendingAlbum;
@synthesize pendingImageUrl;
@synthesize pendingImageLink;

- (id)initWithAppIdentity:(SFAppIdentity *)theAppIdentity {
	self = [super init];
	if(self) {
		statusObserver = [[AppStatusObserver alloc] initWithBecomeActiveDelay:0];
		[statusObserver setDelegate:self];

		appIdentity = theAppIdentity;
	}
	return self;
}

- (BOOL)isWebserviceAvailable:(WebService)theWebservice withErrorString:(NSString **)error {
	if (theWebservice == kFacebook) {
		return YES;
	} else if (theWebservice == kTwitter) {
		if ([TWTweetComposeViewController canSendTweet]) {
			return YES;
		} else {
			*error = NSLocalizedString(@"Twitter not available, check system settings for properly configured Twitter account.",
									   @"Message for misconfigured twitter");
			return NO;
		}
	} else {
		NSAssert(NO, @"Unknown Webservice provided");
		return NO;
	}
}

- (BOOL)isWebaccessAvailable {
	Reachability *r = [Reachability reachabilityForInternetConnection];
	return [r isReachable];
}

- (void)submitToWebservice:(WebService)theWebservice withImage:(UIImage *)image withText:(NSString *)text {
	[self submitToWebservice:(WebService)theWebservice withImage:image withText:text withTrackTitle:nil withArtist:nil withAlbum:nil];
}

- (void)submitToWebservice:(WebService)theWebservice withImage:(UIImage *)image withText:(NSString *)text withTrackTitle:(NSString *)trackTitle withArtist:(NSString *)artist withAlbum:(NSString *)album {
	NSString *error = nil;
	if (![self isWebserviceAvailable:theWebservice withErrorString:&error]) {
		[self.delegate didFailToUseServiceWithMessage:error];
		return;
	}
	if (![self isWebaccessAvailable]) {
		error = NSLocalizedString(@"No internet connection available. Check your connection status.",
								   @"Message for unavailable internet connection for sharing");
		[self.delegate didFailToUseServiceWithMessage:error];
		return;
	}
	
	webservice = theWebservice;
    self.pendingImage = image;
	self.pendingText = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	self.pendingTrackTitle = trackTitle;
	self.pendingArtist = artist;
	self.pendingAlbum = album;
	[self trySubmitPendingImage];
}

- (void)trySubmitPendingImage {
	if(![self hasPendingImage]) {
		return;
	}
	
	if (webservice == kFacebook) {
		if(![self isLoggedIntoFacebook]) {
			[self logIntoFacebook];
			return;
		}
	}
	
	uploadTrials = kMaxImageUploadTrials;
	
	[self submitPendingImage];
}


#pragma mark - Facebook

- (BOOL)isLoggedIntoFacebook {
	return [self.facebook isSessionValid];
}

- (void)logIntoFacebook {
	NSArray *permissions =  [NSArray arrayWithObjects:
		@"publish_stream", nil];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        self.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        self.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    if (![self.facebook isSessionValid]) {
        self.facebook.sessionDelegate = self;
        [self.facebook authorize:permissions];
    } else {
		[self trySubmitPendingImage];
    }
}

- (void)fbDidLogin {
	NSLog(@"fbDidLogin");
	[self trySubmitPendingImage];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[self.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
	NSLog(@"fbDidNotLogin");
	[self removePendingImage];
	[self.delegate didCancelSubmittingImage];
}

- (void)fbSessionInvalidated {
	NSLog(@"fbSessionInvalidated");
}


#pragma mark - Twitpic Post

- (void)removePendingImage {
	self.pendingImage = nil;
}

- (void)submitPendingImage {
	if(uploader == nil) {
		[self createUploader];
	}
    
	[uploader uploadImage:self.pendingImage withMessage:[self twitpicMessage]];
}

- (void)createUploader {
	uploader = [[ImageUploader alloc] init];
	uploader.delegate = self;
}

#pragma mark -
#pragma mark ImageUploaderDelegate

- (void)imageUploaderSucceededWithThumbnailUrl:(NSString *)thumbnailUrl pageUrl:(NSString *)pageUrl {
	[self removePendingImage];

	self.pendingImageUrl = thumbnailUrl;
	self.pendingImageLink = pageUrl;
	[self postMessage];
}

- (void)imageUploaderFailed {
	if (--uploadTrials == 0) {
		[self reportFailure];
	} else {
		[self submitPendingImage];
	}
}

#pragma mark -

- (void)reportSuccess {
	[self removePendingMessageDetails];
	[self.delegate didFinishSubmittingImage];
}

- (void)reportFailure {
	[self removePendingImage];
	[self removePendingMessageDetails];
	[self.delegate didFailSubmittingImage];
}

- (void)reportFailureWithMessage:(NSString *)failMessage {
	[self removePendingImage];
	[self removePendingMessageDetails];
	[self.delegate didFailToUseServiceWithMessage:failMessage];
}

- (void)removePendingMessageDetails {
	self.pendingText = nil;
	self.pendingImageUrl = nil;
	self.pendingImageLink = nil;
}


#pragma mark - Messages

- (NSString *)twitpicMessage {
    NSMutableString *message = [NSMutableString string];
    
    if (self.pendingTrackTitle) {
        [message appendFormat:@"Listening to %@",self.pendingTrackTitle];
        if (self.pendingArtist) {
            [message appendFormat:@" by %@",self.pendingArtist];
        }
        if (self.pendingAlbum) {
            [message appendFormat:@" on album %@",self.pendingAlbum];
        }
        [message appendString:@"."];
	
		if ([self.pendingText length] > 0) {
			[message appendString:@" "];
		}
    }

	[message appendString:self.pendingText];
	
    return message;
}

- (NSString *)twitterMessage {
    NSMutableString *message = [NSMutableString string];
    
	if (self.pendingTrackTitle) {
        [message appendFormat:@"Listening to %@",self.pendingTrackTitle];
        if (self.pendingArtist) {
            [message appendFormat:@" by %@",self.pendingArtist];
        }
        if (self.pendingAlbum) {
            [message appendFormat:@" on album %@",self.pendingAlbum];
        }
		[message appendString:@". "];
	}
	
	if ([self.pendingText length] > 0) {
		[message appendFormat:@"%@ - ",self.pendingText];
	}
	
	[message appendFormat:@"%@",self.pendingImageLink];
    
    return message;
}

- (NSString *)facebookMessage {
    NSMutableString *message = [NSMutableString string];
    
    if (self.pendingTrackTitle) {
        [message appendFormat:@"Currently I'm listening to %@",self.pendingTrackTitle];
        if (self.pendingArtist) {
            [message appendFormat:@" by %@",self.pendingArtist];
        }
        if (self.pendingAlbum) {
            [message appendFormat:@" on album %@",self.pendingAlbum];
        }
        [message appendString:@"."];

		if ([self.pendingText length] > 0) {
			[message appendString:@"\n"];
		}
	}
	
	[message appendString:self.pendingText];
	
    return message;
}

#pragma mark - Post

- (void)postMessage {
	switch (webservice) {
		case kFacebook:
			[self postFacebookMessage];
			break;
		case kTwitter:
			[self postTwitterMessage];
			break;
			
		default:
			return;
	}
}


#pragma mark - Twitter Post

- (void)postTwitterMessage {
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) {
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
			if ([accountsArray count] > 0) {
				// For now, take the first Twitter account
				NSLog(@"%d Twitter accounts found, using the first one",[accountsArray count]);
				ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
				
				TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"]
															 parameters:[NSDictionary dictionaryWithObject:[self twitterMessage] forKey:@"status"]
														  requestMethod:TWRequestMethodPOST];
				
				[postRequest setAccount:twitterAccount];

				[postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
					NSString *failureMessage = nil;
					if ([self isTwitterResponseOk:responseData withUrlResponse:urlResponse withError:error withFailureMessage:&failureMessage]) {
						[self performSelectorOnMainThread:@selector(reportSuccess) withObject:nil waitUntilDone:NO];
					} else {
						[self performSelectorOnMainThread:@selector(reportFailureWithMessage:) withObject:failureMessage waitUntilDone:NO];
					}
				}];
			} else {
				NSString *failMessage = NSLocalizedString(@"No Twitter Accounts found, please check your system settings.",
														  @"Failure message when no Twitter accounts were found");
				[self.delegate didFailToUseServiceWithMessage:failMessage];
			}
        } else {
			NSString *failMessage = NSLocalizedString(@"Without granting access to your Twitter account, this message cannot be shared with that service.",
													  @"Failure message when user declined access to his Twitter account");
			[self.delegate didFailToUseServiceWithMessage:failMessage];
		}
	}];
}

- (BOOL)isTwitterResponseOk:(NSData *)responseData withUrlResponse:(NSHTTPURLResponse *)urlResponse withError:(NSError *)error withFailureMessage:(NSString **)failureMessage {
	NSString *fail = NSLocalizedString(@"Problem with posting to Twitter, please try again.",
									   @"Failure message for errorneous Twitter response");
	if ([urlResponse statusCode] != 200) {
		//NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
		*failureMessage = fail;
		return NO;
	}
		
	return YES;
}


#pragma mark - Facebook Post

- (void)postFacebookMessage {
	NSString *name = NSLocalizedString(@"My music collection",
		@"Name for facebook posts");
	NSString *caption = NSLocalizedString(@"in Sonarflow",
		@"Caption for facebook posts");
	NSString *description = NSLocalizedString(@"Browse your music visually with Sonarflow.",
		@"Description for facebook posts");
	NSString *properties = [self createMessageProperties];
	NSMutableDictionary *params = [NSMutableDictionary
								   dictionaryWithObjectsAndKeys:
								   self.pendingImageUrl, @"picture",
								   self.pendingImageLink, @"link",
								   name, @"name",
								   caption, @"caption", 
								   description, @"description",
								   [self facebookMessage], @"message",
								   properties, @"properties",
								   nil];
	NSLog(@"fb post with params: %@",params);
	[self.facebook requestWithGraphPath:@"me/feed"
							  andParams:params andHttpMethod:@"POST"
							andDelegate:self];
}

- (NSString *)createMessageProperties {
	NSString *getApp = NSLocalizedString(@"Get the free App",
                                         @"Text next to the App Store link in Facebook messages.");
	NSString *visitFanpage = NSLocalizedString(@"Visit Fanpage",
		@"Text next to the Sonarflow Facebook page in Facebook messages.");
	NSString *getAppLink = [self createAppLink];
	NSString *visitFanpageLink = [self createFanpageLink];

    NSString *buyTrack = NSLocalizedString(@"Buy the Track",
                                           @"Text next to the iTunes link in Facebook messages.");
	NSString *getTrackLink = [self createTrackLink];
    
    NSMutableString *properties = [NSMutableString stringWithString:@"{"];
    if (getTrackLink) {
        [properties appendFormat:@"\"%@\":%@,",buyTrack, getTrackLink];
    }
    [properties appendFormat:@"\"%@\":%@,\"%@\":%@}",
     getApp, getAppLink,
     visitFanpage, visitFanpageLink];

    return properties;
}

- (NSString *)createTrackLink {
    if (!self.pendingTrackTitle) {
        return nil;
    }
    
    NSString *itunesText = NSLocalizedString(@"on iTunes Store",
                                             @"Title of the iTunes track link in Facebook messages.");
	NSString *linkText = [NSString stringWithFormat:@"%@ %@",self.pendingTrackTitle,itunesText];
	NSString *url = [NSString stringWithFormat:@"http://clk.tradedoubler.com/click?p=%@&a=%@&url=http://itunes.apple.com/WebObjects/MZSearch.woa/wa/search?songTerm=%@&artistTerm=%@&albumTerm=%@&composerTerm=&partnerId=2003",
					 self.tradedoublerProgramID,self.tradedoublerWebsiteID,
                     self.pendingTrackTitle?:@"",self.pendingArtist?:@"",self.pendingAlbum?:@""];
	return [self createLinkWithText:linkText
                                url:url];
}

- (NSString *)createAppLink {
	NSString *linkText = NSLocalizedString(@"Sonarflow on Apple App Store",
                                           @"Title of the App Store link in Facebook messages.");
	return [self createLinkWithText:linkText
                                url:[appIdentity storeURL]];
}

- (NSString *)createFanpageLink {
	NSString *linkText = NSLocalizedString(@"Sonarflow on Facebook",
		@"Title of the Sonarflow Facebook page link in Facebook messages.");
	return [self createLinkWithText:linkText
								url:@"http://www.facebook.com/sonarflow"];
}

- (NSString *)createLinkWithText:(NSString *)text url:(NSString *)url {
	return [NSString stringWithFormat:@"{\"text\":\"%@\",\"href\":\"%@\"}", text, [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"FBRequest error: %@", error);

	[self reportFailure];
}

- (void)request:(FBRequest *)request didLoad:(id)result {
	[self reportSuccess];
}

- (Facebook *)facebook {
	if(facebook == nil) {
		facebook = [[Facebook alloc] initWithAppId:[appIdentity facebookAppId] andDelegate:self];
	}
	return facebook;
}

#pragma mark -
#pragma mark AppStatusObserverDelegate

- (void)appDidBecomeActive {
	if([self hasPendingImage] && ![self isLoggedIntoFacebook]) {
		[self removePendingImage];
		[self.delegate didCancelSubmittingImage];
	}
}

- (BOOL)hasPendingImage {
	return self.pendingImage != nil;
}

@end

#import "AdMobHandler.h"

#import "GADBannerView.h"
#import "Reachability.h"
#import "NSString+DocumentsPath.h"

@interface AdMobHandler ()

@end


@implementation AdMobHandler {
	@private
	//Workaround for #158
	BOOL adMobHasSeenNetwork;
	BOOL canReachNetwork;
	Reachability *networkReachability;
}

- (id)init {
	self = [super init];
	if(self) {
		[self loadAdMobStatus];
		[self monitorNetwork];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (GADBannerView *)requestAd {
	if(![self canRequestAd]) {
		return nil;
	}
    
    GADBannerView *bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0.0,
                                                                                0.0,
                                                                                GAD_SIZE_320x50.width,
                                                                                GAD_SIZE_320x50.height)];
    bannerView.delegate = self;
    bannerView.rootViewController = self.viewController;
    bannerView.adUnitID = self.publisherId;
    [bannerView loadRequest:[GADRequest request]];
    
	return bannerView;
}

#pragma mark -
#pragma mark GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    [self receivedAd];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"Failed to receive ad");
}

- (void)adViewWillPresentScreen:(GADBannerView *)adView
{
    NSLog(@"adViewWillPresentScreen");
}

- (void)adViewWillDismissScreen:(GADBannerView *)adView
{
    NSLog(@"adViewWillDismissScreen");
}

- (void)adViewDidDismissScreen:(GADBannerView *)adView
{
    NSLog(@"adViewDidDismissScreen");
}

- (void)adViewWillLeaveApplication:(GADBannerView *)adView
{
    NSLog(@"adViewWillLeaveApplication");
}

//- (NSArray *)testDevices
//{
//	return [NSArray arrayWithObject:[[UIDevice currentDevice] uniqueIdentifier]];
//}

#pragma mark -
#pragma mark Private Methods

- (void)receivedAd {
	if(!adMobHasSeenNetwork) {
		adMobHasSeenNetwork = YES;
		[self saveAdMobStatus];
		
		if(networkReachability != nil) {
			[[NSNotificationCenter defaultCenter] removeObserver:self];
			networkReachability = nil;
		}
	}	
}

- (NSString *)statusFile {
	return [NSString pathForDocumentFile:@"adMob.plist"];
}

- (void)saveAdMobStatus {
	NSArray *keys = [NSArray arrayWithObject:@"adMobHasSeenNetwork"];

	NSDictionary *dict = [self dictionaryWithValuesForKeys:keys];
	
	[dict writeToFile:[self statusFile] atomically:YES];
}

- (void)loadAdMobStatus {
	NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:[self statusFile]];
	if(dict == nil) {
		adMobHasSeenNetwork = NO;
		return;
	}
	
	[self setValuesForKeysWithDictionary:dict];
}

- (BOOL)canRequestAd {
	//Issue #158: AdMob crashes if it tries to request an ad and there is
	//no network connection AND never has been one while the app was running
	return adMobHasSeenNetwork || canReachNetwork;
}

- (void)monitorNetwork {
	if(!adMobHasSeenNetwork) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(reachabilityChanged:)
													 name:kReachabilityChangedNotification
												   object:nil];
		
		networkReachability = [Reachability reachabilityForInternetConnection];
		[networkReachability startNotifier];
		[self updateNetworkStatus];
	}
}

- (void)updateNetworkStatus {
	NetworkStatus netStatus = [networkReachability currentReachabilityStatus];
	if(netStatus == NotReachable) {
		canReachNetwork = NO;
	}
	else {
		canReachNetwork = YES;
	}
	NSLog(@"Can reach network: %d", (int)canReachNetwork);
}

- (void)reachabilityChanged:(NSNotification *)note {
	[self updateNetworkStatus];
}

@end

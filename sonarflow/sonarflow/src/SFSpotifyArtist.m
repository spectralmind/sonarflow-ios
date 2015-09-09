#import "SFSpotifyArtist.h"

#import "MediaViewControllerFactory.h"
#import "RootKey.h"
#import "SFSpotifyTrack.h"
#import "SFSpotifyPlayer.h"
#import "SPArtist.h"
#import "SPArtistBrowse.h"
#import "SPImage.h"
#import "SPSession.h"

@implementation SFSpotifyArtist {
	SPImage *image;
}


-(id)initWithArtist:(SPArtist *)theArtist key:(id)theKey player:(SFSpotifyPlayer *)thePlayer {
	self = [super initWithName:theArtist.name key:theKey player:thePlayer];
	if(self == nil) {
		return nil;
	}
	
	SPArtistBrowse *browse = [[SPArtistBrowse alloc] initWithArtist:theArtist inSession:[SPSession sharedSession] type:SP_ARTISTBROWSE_NO_ALBUMS];
	
	[SPAsyncLoading waitUntilLoaded:browse timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedBrowse, NSArray *notLoaded) {
		if(browse.firstPortrait == nil) {
			return;
		}

		[SPAsyncLoading waitUntilLoaded:browse.firstPortrait timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedPortraits, NSArray *notLoaded) {
			if (loadedPortraits.count == 0) {
				return;
			}
			
			SPImage *firstImage = [loadedPortraits objectAtIndex:0];
			
			[SPAsyncLoading waitUntilLoaded:firstImage timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *images, NSArray *notLoaded) {
				if (images.count == 0) {
					return;
				}
				
				image = firstImage;
			}];
		}];
	}];
	
	return self;
}

- (BOOL)mayHaveImage {
	return YES;
}

- (UIImage *)imageWithSize:(CGSize)size {
	return image.image;
}

- (NSString *)artistNameForDiscovery {
	return self.name;
}

- (BOOL)hasDetailViewController {
	return YES;
}

- (UIViewController *)createDetailViewControllerWithFactory:(MediaViewControllerFactory *)factory {
	return [factory viewControllerForArtist:[self tracksProxy] singleArtist:YES];
}

@end

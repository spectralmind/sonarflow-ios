#import "ArtworkFactory.h"

#import <MediaPlayer/MediaPlayer.h>
#import "DeviceInformation.h"
#import "ImageFactory.h"

static const NSTimeInterval kDelayArtworkInterval = 120;

@interface ArtworkFactory ()

@property (nonatomic, strong) NSDate *delayArtworkStartDate;

@end


@implementation ArtworkFactory {
	ImageFactory *imageFactory;
}

- (id)initWithImageFactory:(ImageFactory *)theImageFactory {
    self = [super init];
    if (self) {
		imageFactory = theImageFactory;
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter addObserver:self
							   selector:@selector(mediaLibraryChanged:)
								   name:MPMediaLibraryDidChangeNotification
								 object:nil];
    }
    return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@synthesize delayArtworkStartDate;

- (UIImage *)artworkForMediaItem:(MPMediaItem *)item withSize:(CGSize)size {
	if([DeviceInformation isRunningOnOSVersion5OrNewer] == NO) {
		//Workaround for #147: Requesting artwork of new albums too soon after syncing destroys
		//the 'get artwork' process.
		if(self.delayArtworkStartDate != nil) {
			NSTimeInterval delta = [self.delayArtworkStartDate timeIntervalSinceNow];
			if(delta > -kDelayArtworkInterval) {
				return nil;
			}

			self.delayArtworkStartDate = nil;
		}
	}

	UIImage *image = [[item valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:size];
	if(image == nil) {
		return [imageFactory defaultCoverForSize:size];
	}
	
	return image;
}

- (void)mediaLibraryChanged:(id)notification {
	//Used for the "delayArtwork" workaround for #147
	self.delayArtworkStartDate = [[MPMediaLibrary defaultMediaLibrary] lastModifiedDate];
}

@end

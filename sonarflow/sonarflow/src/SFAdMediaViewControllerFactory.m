#import "SFAdMediaViewControllerFactory.h"

#import "AdMobHandler.h"
#import "SFAdvertisingSection.h"

@implementation SFAdMediaViewControllerFactory {
	AdMobHandler *adHandler;
}

- (id)initWithButtonFactory:(DismissButtonFactory *)theButtonFactory playlistEditor:(NSObject<PlaylistEditor> *)thePlaylistEditor imageFactory:(ImageFactory *)theImageFactory playbackDelegate:(id<PlaybackDelegate>)thePlaybackDelegate player:(NSObject<SFMediaPlayer> *)thePlayer library:(NSObject<SFMediaLibrary> *)theLibrary adHandler:(AdMobHandler *)theAdHandler {
    self = [super initWithButtonFactory:theButtonFactory playlistEditor:thePlaylistEditor imageFactory:theImageFactory playbackDelegate:thePlaybackDelegate player:thePlayer library:theLibrary];
    if (self) {
		adHandler = theAdHandler;
    }
    return self;
}


- (SFSectionsTableViewController *)viewControllerWithTitle:(NSString *)title sections:(NSArray *)sections {
	id<SFTableViewSection> adSection = [[SFAdvertisingSection alloc] initWithAdMobHandler:adHandler];
	return [super viewControllerWithTitle:title sections:
			[sections arrayByAddingObject:adSection]];
}

@end

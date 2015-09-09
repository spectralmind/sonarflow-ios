#import "MediaViewControllerFactory.h"

#import "DismissButtonFactory.h"
#import "ImageFactory.h"
#import "SFAddPlaylistSection.h"
#import "SFAdvertisingSection.h"
#import "SFAlbumInfoSection.h"
#import "SFAllChildrenRowSection.h"
#import "SFArtistInfoSection.h"
#import "SFAutomaticPlaylistsSection.h"
#import "SFEditPlaylistSection.h"
#import "SFMediaChildrenSection.h"
#import "SFMediaItem.h"
#import "SFMediaLibrary.h"
#import "SFMediaPlayer.h"
#import "SFPlaylist.h"
#import "SFSectionsTableViewController.h"
#import "SFTracksSection.h"
#import "SFUserPlaylistsSection.h"

#ifndef SF_SPOTIFY
	#import "SFITunesDiscoveredArtist.h"
	#import "SFITunesTracksSection.h"
#endif

@implementation MediaViewControllerFactory {
	DismissButtonFactory *buttonFactory;
	NSObject<PlaylistEditor> *playlistEditor;
	id<PlaybackDelegate> playbackDelegate;
	NSObject<SFMediaLibrary> *library;
}

- (id)initWithButtonFactory:(DismissButtonFactory *)theButtonFactory playlistEditor:(NSObject<PlaylistEditor> *)thePlaylistEditor imageFactory:(ImageFactory *)theImageFactory playbackDelegate:(id<PlaybackDelegate>)thePlaybackDelegate player:(NSObject<SFMediaPlayer> *)thePlayer library:(NSObject<SFMediaLibrary> *)theLibrary {
    self = [super init];
    if (self) {
		buttonFactory = theButtonFactory;
		playlistEditor = thePlaylistEditor;
		_imageFactory = theImageFactory;
		playbackDelegate = thePlaybackDelegate;
		_player = thePlayer;
		library = theLibrary;
    }
    return self;
}


- (UIViewController *)viewControllerForGenre:(id<SFMediaItem>)genre {
	SFAllChildrenRowSection *allChildrenSection = [[SFAllChildrenRowSection alloc] initWithMediaItem:genre allElementsTitle:NSLocalizedString(@"All Albums", @"Description for all children of artists")];
	id<SFTableViewSection> section = [self childrenSectionForMediaItem:genre withTitle:@"Artists" albumNames:NO artistNames:NO images:NO];
	return [self viewControllerWithTitle:genre.name sections:[NSArray arrayWithObjects:allChildrenSection, section, nil]];
}

- (UIViewController *)viewControllerForArtist:(id<SFMediaItem>)artist singleArtist:(BOOL)singleArtist {
	NSMutableArray *sections = [NSMutableArray arrayWithCapacity:3];
	if(singleArtist) {
		SFArtistInfoSection *section = [[SFArtistInfoSection alloc] initWithMediaItem:artist];
		[sections addObject:section];
	}
	[sections addObjectsFromArray:[self childrenSectionsForArtist:artist singleArtist:singleArtist]];
	return [self viewControllerWithTitle:artist.name sections:sections];
}

- (NSArray *)childrenSectionsForArtist:(NSObject<SFMediaItem> *)artist singleArtist:(BOOL)singleArtist {
	id<SFTableViewSection> allChildrenSection = [[SFAllChildrenRowSection alloc] initWithMediaItem:artist allElementsTitle:NSLocalizedString(@"All Tracks", @"Description for all children of albums")];
	id<SFTableViewSection> childrenSection = [self childrenSectionForMediaItem:artist withTitle:@"Albums" albumNames:NO artistNames:!singleArtist images:YES];
	return [NSArray arrayWithObjects:allChildrenSection, childrenSection, nil];
}

- (id<SFTableViewSection>)childrenSectionForMediaItem:(id<SFMediaItem>)mediaItem withTitle:(NSString *)title albumNames:(BOOL)showAlbumNames artistNames:(BOOL)showArtistNames  images:(BOOL)showImages {
	SFMediaChildrenSection *childrenSection = [[SFMediaChildrenSection alloc] initWithMediaItem:mediaItem];
	childrenSection.title = title;
	childrenSection.showAlbumName = showAlbumNames;
	childrenSection.showArtistName = showArtistNames;
	childrenSection.showImage = showImages;
	return childrenSection;
}

- (UIViewController *)viewControllerForAlbum:(id<SFMediaItem>)album showAlbums:(BOOL)theShowAlbums showArtists:(BOOL)theShowArtists showTracksNumber:(BOOL)theShowTrackNumbers {
	SFAlbumInfoSection *headerSection = [[SFAlbumInfoSection alloc] initWithMediaItem:album];
	id<SFTableViewSection> tracksSection = [self tracksSectionForMediaItem:album withAlbumNames:theShowAlbums artistNames:theShowArtists trackNumbers:theShowTrackNumbers];
	return [self viewControllerWithTitle:album.name sections:[NSArray arrayWithObjects:headerSection, tracksSection, nil]];
}

- (UIViewController *)viewControllerForDiscoveredArtist:(id<SFMediaItem>)artist {
	SFArtistInfoSection *artistInfoSection = [[SFArtistInfoSection alloc] initWithMediaItem:artist];
	id<SFTableViewSection> tracksSection = [self tracksSectionForMediaItem:artist withAlbumNames:YES artistNames:NO trackNumbers:YES];
	return [self viewControllerWithTitle:artist.name sections:[NSArray arrayWithObjects:artistInfoSection, tracksSection, nil]];
}

- (id<SFTableViewSection>)tracksSectionForMediaItem:(NSObject<SFMediaItem> *)mediaItem withAlbumNames:(BOOL)showAlbumNames artistNames:(BOOL)showArtistNames  trackNumbers:(BOOL)showTrackNumbers{
	//TODO: Refactor to use a SFTrackSection with different SFTrackCellFactory (tbd) instance
	SFTracksSection *tracksSection;
#ifndef SF_SPOTIFY
	if([mediaItem isKindOfClass:[SFITunesDiscoveredArtist class]]) {
		tracksSection = [[SFITunesTracksSection alloc] initWithMediaItem:mediaItem imageFactory:self.imageFactory];
		tracksSection.title = @"Tracks on iTunes";
	}
	else
#endif
	{
		tracksSection = [[SFTracksSection alloc] initWithMediaItem:mediaItem imageFactory:self.imageFactory];
		tracksSection.title = @"Tracks";
	}
	
	tracksSection.showAlbumName = showAlbumNames;
	tracksSection.showArtistName = showArtistNames;
	tracksSection.showTrackNumbers = showTrackNumbers;
	tracksSection.player = self.player;
	return tracksSection;
}

- (SFSectionsTableViewController *)viewControllerWithTitle:(NSString *)title sections:(NSArray *)sections {
	SFSectionsTableViewController *viewController = [[SFSectionsTableViewController alloc] initWithSections:sections playlistEditor:playlistEditor factory:self];
	viewController.navigationItem.title = title;
	viewController.navigationItem.rightBarButtonItem = [buttonFactory closeButtonForViewController:viewController];
	return viewController;	
}

- (UIViewController *)viewControllerForPlaylistsWithDelegate:(id<SFPlaylistsViewDelegate>)delegate asPicker:(BOOL)asPicker {
	SFAutomaticPlaylistsSection *automaticSection = [[SFAutomaticPlaylistsSection alloc] init];
	automaticSection.playlistDelegate = delegate;
	automaticSection.showDisclosureIndicator = !asPicker;
	automaticSection.automaticPlaylists = self.player.automaticPlaylists;
	automaticSection.title = [SFAutomaticPlaylistsSection defaultTitle];
	SFAddPlaylistSection *addSection = [[SFAddPlaylistSection alloc] initWithLibrary:library];
	addSection.playlistDelegate = delegate;
	addSection.title = [SFUserPlaylistsSection defaultTitle];
	SFUserPlaylistsSection *userSection = [[SFUserPlaylistsSection alloc] initWithLibrary:library];
	userSection.playlistDelegate = delegate;
	userSection.showDisclosureIndicator = !asPicker;
	NSString *title = NSLocalizedString(@"Playlists",
										@"Title for playlist list view");
	NSArray *sections;
	if (asPicker) {
		sections = @[addSection, userSection];
	}
	else {
		sections = @[automaticSection, addSection, userSection];
	}
	SFSectionsTableViewController *viewController = [self viewControllerWithTitle:title sections:sections];
	viewController.editable = YES;
	if(asPicker) {
		viewController.navigationItem.rightBarButtonItem = [buttonFactory cancelButtonForViewController:viewController];
	}
	else {
		viewController.navigationItem.rightBarButtonItem = [buttonFactory doneButtonForViewController:viewController];
		
	}
	return viewController;
}

- (UIViewController *)viewControllerForPlaylist:(NSObject<SFPlaylist> *)playlist {
	NSMutableArray *sections = [NSMutableArray arrayWithCapacity:2];
	if([playlist isReadOnly] == NO) {
		[sections addObject:[[SFEditPlaylistSection alloc] initWithPlaylist:playlist]];
	}
	[sections addObject:[self tracksSectionForMediaItem:playlist withAlbumNames:YES artistNames:YES trackNumbers:NO]];
	SFSectionsTableViewController *viewController = [self viewControllerWithTitle:playlist.name sections:sections];
	viewController.editable = ![playlist isReadOnly];
	return viewController;
}

- (UIViewController *)viewControllerForTrack:(id<SFMediaItem>)track {
	id<SFTableViewSection> section = [self tracksSectionForMediaItem:track withAlbumNames:NO artistNames:NO trackNumbers:NO];
	section.title = nil;
	
	SFSectionsTableViewController *viewController = [self viewControllerWithTitle:track.name sections:@[section]];
	return viewController;

}

@end

#import "SFAutomaticPlaylistsSection.h"

#import "SFPlaylist.h"
#import "SFPlaylistsViewDelegate.h"

@implementation SFAutomaticPlaylistsSection

+ (NSString *)defaultTitle {
	return NSLocalizedString(@"Automatic", @"Title for list of automatic playlists");
}


@synthesize automaticPlaylists;

- (NSUInteger)numberOfRows {
	return [self.automaticPlaylists count];
}

- (NSObject<SFPlaylist> *)playlistForRow:(NSUInteger)row {
	return [self.automaticPlaylists objectAtIndex:row];
}

@end

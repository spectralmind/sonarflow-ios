#import "SFAbstractPlaylistsSection.h"

@protocol SFMediaLibrary;
@protocol SFPlaylistsViewDelegate;
@class AutomaticPlaylists;

@interface SFUserPlaylistsSection : SFAbstractPlaylistsSection

+ (NSString *)defaultTitle;

- (id)initWithLibrary:(NSObject<SFMediaLibrary> *)theLibrary;

@end

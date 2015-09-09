#import "SFAbstractPlaylistsSection.h"

@interface SFAutomaticPlaylistsSection : SFAbstractPlaylistsSection

+ (NSString *)defaultTitle;

@property (nonatomic, strong) NSArray *automaticPlaylists;

@end

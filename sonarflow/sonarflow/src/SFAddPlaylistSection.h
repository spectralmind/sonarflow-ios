#import <Foundation/Foundation.h>

#import "SFTableViewSection.h"

@protocol SFMediaLibrary;
@protocol SFPlaylist;
@protocol SFPlaylistsViewDelegate;

@interface SFAddPlaylistSection : NSObject <SFTableViewSection>

- (id)initWithLibrary:(NSObject<SFMediaLibrary> *)theLibrary;


@property (nonatomic, weak) id<SFPlaylistsViewDelegate> playlistDelegate;

@end

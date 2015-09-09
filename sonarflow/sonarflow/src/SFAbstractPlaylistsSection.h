#import <Foundation/Foundation.h>

#import "SFTableViewSection.h"

@protocol SFPlaylist;
@protocol SFPlaylistsViewDelegate;

@interface SFAbstractPlaylistsSection : NSObject <SFTableViewSection>

@property (nonatomic, weak) id<SFPlaylistsViewDelegate> playlistDelegate;
@property (nonatomic, assign) BOOL showDisclosureIndicator;


//Abstract
- (NSObject<SFPlaylist> *)playlistForRow:(NSUInteger)row;

@end

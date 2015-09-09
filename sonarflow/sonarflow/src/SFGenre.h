#import <UIKit/UIKit.h>

#import "CollectionWithChildren.h"
#import "SFRootItem.h"
#import "SFDiscoverableItem.h"

@class GenreDefinition;

@interface SFGenre : CollectionWithChildren <SFRootItem, SFDiscoverableItem>

+ (id)keyForGenreName:(NSString *)genreName;

- (id)initWithGenreDefinition:(GenreDefinition *)theGenreDefinition player:(SFNativeMediaPlayer *)thePlayer;

@property (nonatomic, readwrite, assign) CGFloat relativeSize;

- (NSArray *)pushTracksIntoArtistChildren;

@end

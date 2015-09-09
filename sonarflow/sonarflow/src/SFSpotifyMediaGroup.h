#import "SFSpotifyMediaItem.h"

@interface SFSpotifyMediaGroup : SFSpotifyMediaItem

@property (nonatomic, readwrite, retain) NSArray *children;
@property (nonatomic, readwrite, assign) NSUInteger size;

@end

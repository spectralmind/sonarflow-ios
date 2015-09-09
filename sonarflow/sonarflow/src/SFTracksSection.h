#import "SFAbstractMediaItemSection.h"

@protocol SFMediaPlayer;
@class ImageFactory;

@interface SFTracksSection : SFAbstractMediaItemSection

- (id)initWithMediaItem:(NSObject<SFMediaItem> *)theMediaItem imageFactory:(ImageFactory *)theImageFactory;

@property (nonatomic, readonly) ImageFactory *imageFactory;
@property (nonatomic, assign) BOOL showTrackNumbers;
@property (nonatomic, strong) NSObject<SFMediaPlayer> *player;

@end

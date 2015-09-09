#import <Foundation/Foundation.h>

#import "SFAbstractMediaItemComposite.h"
#import "SFNativeMediaItem.h"

@class SFNativeMediaPlayer;

@interface SFNativeMediaItemComposite : SFAbstractMediaItemComposite <SFNativeMediaItem>

- (id)initWithName:(NSString *)theName mediaItems:(NSArray *)theMediaItems player:(SFNativeMediaPlayer *)thePlayer;

@property (nonatomic, readonly) SFNativeMediaPlayer *player;

@end

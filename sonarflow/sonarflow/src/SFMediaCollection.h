#import <Foundation/Foundation.h>

#import "SFNativeMediaItem.h"

@class SFNativeMediaPlayer;

@interface SFMediaCollection : NSObject <SFNativeMediaItem>

- (id)initWithKey:(id)theKey;
- (id)initWithName:(NSString *)theName player:(SFNativeMediaPlayer *)thePlayer;
- (id)initWithKey:(id)theKey name:(NSString *)theName player:(SFNativeMediaPlayer *)thePlayer;

@property (nonatomic, readonly) SFNativeMediaPlayer *player;
@property (nonatomic, readwrite, weak) id<SFMediaItem> parent;

@property (nonatomic, strong) NSString *sortableName;

@end
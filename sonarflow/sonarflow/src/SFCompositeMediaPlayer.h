#import <Foundation/Foundation.h>

#import "SFMediaPlayer.h"

@interface SFCompositeMediaPlayer : NSObject <SFMediaPlayer>

- (id)initWithPlayers:(NSArray *)thePlayers;

@end

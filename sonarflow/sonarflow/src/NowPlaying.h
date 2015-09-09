//
//  NowPlaying.h
//  Sonarflow
//
//  Created by Raphael Charwot on 13.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFPlaylist.h"
#import "SFNativeMediaItem.h"

@protocol SFNativeTrack;
@class SFNativeMediaPlayer;

@interface NowPlaying : NSObject <SFPlaylist, SFNativeMediaItem>

- (id)initWithPlayer:(SFNativeMediaPlayer *)thePlayer;

@property (nonatomic, readonly, strong) NSArray *tracks;

- (void)nowPlayingTrackChanged:(NSObject<SFNativeTrack> *)track;
- (void)queueChanged:(NSArray *)queuedTracks;

@end

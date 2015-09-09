//
//  AutomaticPlaylists.h
//  Sonarflow
//
//  Created by Raphael Charwot on 15.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SFNativeTrack;
@protocol SFPlaylist;
@class History;
@class NowPlaying;

@interface AutomaticPlaylists : NSObject

@property (nonatomic, readonly) History *history;
@property (nonatomic, readonly) NowPlaying *nowPlaying;

- (id)initWithHistory:(History *)theHistory
		   nowPlaying:(NowPlaying *)theNowPlaying;

- (NSUInteger)numPlaylists;
- (NSObject<SFPlaylist> *)playlistAtIndex:(NSUInteger)index;

- (void)nowPlayingTrackChanged:(NSObject<SFNativeTrack> *)track;
- (void)queueChanged:(NSArray *)queuedTracks;

@end
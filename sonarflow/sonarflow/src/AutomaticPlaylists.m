//
//  AutomaticPlaylists.m
//  Sonarflow
//
//  Created by Raphael Charwot on 15.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import "AutomaticPlaylists.h"
#import "History.h"
#import "NowPlaying.h"

@implementation AutomaticPlaylists

- (id)initWithHistory:(History *)theHistory
		   nowPlaying:(NowPlaying *)theNowPlaying {
	if(self = [super init]) {
		history = theHistory;
		nowPlaying = theNowPlaying;
	}
	return self;
}


@synthesize history;
@synthesize nowPlaying;

- (NSUInteger)numPlaylists {
	return 2;
}

- (NSObject<SFPlaylist> *)playlistAtIndex:(NSUInteger)index {
	if(index == 0) {
		return nowPlaying;
	}
	else {
		return history;
	}
}

- (void)nowPlayingTrackChanged:(NSObject<SFNativeTrack> *)track {
	[history nowPlayingTrackChanged:track];
	[nowPlaying nowPlayingTrackChanged:track];
}

- (void)queueChanged:(NSArray *)queuedTracks {
	[nowPlaying queueChanged:queuedTracks];
}

@end

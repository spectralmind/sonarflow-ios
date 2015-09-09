//
//  NowPlaying.m
//  Sonarflow
//
//  Created by Raphael Charwot on 13.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import "NowPlaying.h"
#import "SFNativeTrack.h"
#import "SFNativeMediaPlayer.h"

@interface NowPlaying ()

@property (nonatomic, readwrite, strong) NSArray *children;

@end


@implementation NowPlaying {
	SFNativeMediaPlayer *player;
}

- (id)initWithPlayer:(SFNativeMediaPlayer *)thePlayer {
    self = [super init];
    if (self) {
		player = thePlayer;
		children = [[NSArray alloc] init];
    }
    return self;
}


@synthesize children;

- (id)key {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id<SFMediaItem>)parent {
	return nil;
}

- (NSNumber *)duration {
	return nil; //Not needed atm.
}

- (BOOL)mayHaveChildren {
	return YES;
}

- (BOOL)showAsBubble {
	return NO;
}

- (BOOL)hasDetailViewController {
	return YES;
}

- (UIViewController *)createDetailViewControllerWithFactory:(MediaViewControllerFactory *)factory {
	//TODO
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (BOOL)mayHaveImage {
	return NO;
}

- (void)startPlayback {
	[player playMediaItem:self];
}

- (void)startPlaybackAtChildIndex:(NSUInteger)childIndex; {
	[player playMediaItem:self startingAtIndex:childIndex];
}

- (NSComparisonResult)compareKeys:(id<SFMediaItem>)other {
	[self doesNotRecognizeSelector:_cmd];
	return NSOrderedSame;
}

- (NSArray *)tracks {
	return self.children;
}

- (void)nowPlayingTrackChanged:(NSObject<SFNativeTrack> *)track {
	if([self childrenContainTrack:track] == NO) {
		[self replaceChildrenWithTrack:track];
	}
}

- (BOOL)childrenContainTrack:(NSObject<SFNativeTrack> *)newTrack {
	if(newTrack == nil) {
		return NO;
	}

	for(id<SFNativeTrack> track in self.children) {
		if([track isEquivalentToAudioTrack:newTrack]) {
			return YES;
		}
	}
	
	return NO;
}

- (void)replaceChildrenWithTrack:(NSObject<SFNativeTrack> *)newTrack {
	if(newTrack == nil) {
		self.children = [NSArray array];
	}
	else {
		self.children = [NSArray arrayWithObject:newTrack];
	}
}

- (void)queueChanged:(NSArray *)queuedTracks {
	self.children = [queuedTracks copy];
}

#pragma mark -
#pragma mark SFPlaylist

- (NSUInteger)numTracks {
	return [self.children count];
}

- (BOOL)isReadOnly {
	return YES;
}

- (NSString *)name {
	return NSLocalizedString(@"Now Playing",
							 @"Title for playlist of currently playing tracks");
}

@end

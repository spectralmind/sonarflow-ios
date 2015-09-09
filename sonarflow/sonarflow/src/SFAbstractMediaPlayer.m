#import "SFAbstractMediaPlayer.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>

#import "SFAudioTrack.h"
#import "SFMediaItem.h"
#import "SFMediaPlayer.h"
#import "SFPlaybackQueue.h"

static const CGSize kArtworkSize = {256, 256};

@interface SFAbstractMediaPlayer () <AVAudioSessionDelegate>

- (void)handleAudioRouteChange:(NSDictionary *)change;

@end


void AudioRouteChagneListener(void *inClientData, AudioSessionPropertyID inID, UInt32 inDataSize, const void *inData) {
	if(inID != kAudioSessionProperty_AudioRouteChange) {
		return;
	}
	
	CFDictionaryRef change = inData;
	SFAbstractMediaPlayer *player = (__bridge SFAbstractMediaPlayer *)inClientData;
	[player handleAudioRouteChange:(__bridge NSDictionary *)change];
}


@implementation SFAbstractMediaPlayer

+ (BOOL)isAudioTrack:(id<SFAudioTrack>)audioTrack equivalentToMediaItem:(id<SFMediaItem>)mediaItem {
	if([mediaItem conformsToProtocol:@protocol(SFAudioTrack)] == NO) {
		return NO;
	}
	
	return [audioTrack isEquivalentToAudioTrack:(id<SFAudioTrack>)mediaItem];
}


@dynamic playbackState;
@dynamic nowPlaying;
@dynamic nowPlayingLeaf;
@synthesize nowPlayingLeafPlaybackTime;
@synthesize nowPlayingLeafDuration;
@dynamic automaticPlaylists;
@dynamic shuffle;

- (void)skipToNextItem {
	[self doesNotRecognizeSelector:_cmd];
}

- (void)skipToPrevousItem {
	[self doesNotRecognizeSelector:_cmd];
}

- (void)setProgress:(float)progress {
	[self doesNotRecognizeSelector:_cmd];
}

- (void)pausePlayback {
	[self doesNotRecognizeSelector:_cmd];
}

- (void)resumePlayback {
	[self doesNotRecognizeSelector:_cmd];
}

- (void)togglePlayback {
	if(self.playbackState == SFPlaybackStatePlaying) {
		[self pausePlayback];
	}
	else {
		[self resumePlayback];
	}
}

- (void)publishNowPlayingInfoForQueue:(SFPlaybackQueue *)queue {
	id<SFMediaItem, SFAudioTrack> track = queue.currentItem;
	if(track == nil) {
		[[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:[NSDictionary dictionary]];
		return;
	}
	
	NSMutableDictionary *trackInfo = [NSMutableDictionary dictionaryWithCapacity:9];
	[trackInfo setObject:track.name forKey:MPMediaItemPropertyTitle];
	[trackInfo setObject:[track artistName] forKey:MPMediaItemPropertyArtist];
	[trackInfo setObject:[track albumName] forKey:MPMediaItemPropertyAlbumTitle];
	[trackInfo setObject:[track albumArtistName] forKey:MPMediaItemPropertyAlbumArtist];
	if(track.duration != nil) {
		[trackInfo setObject:track.duration forKey:MPMediaItemPropertyPlaybackDuration];
	}
	if([track respondsToSelector:@selector(artwork)]) {
		MPMediaItemArtwork *artwork = [track artwork];
		if(artwork != nil) {
			[trackInfo setObject:artwork forKey:MPMediaItemPropertyArtwork];
		}
	}
	[trackInfo setObject:[NSNumber numberWithFloat:self.nowPlayingLeafPlaybackTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
	[trackInfo setObject:[NSNumber numberWithUnsignedInteger:queue.currentItemIndex] forKey:MPNowPlayingInfoPropertyPlaybackQueueIndex];
	[trackInfo setObject:[NSNumber numberWithUnsignedInteger:[queue.queue count]] forKey:MPNowPlayingInfoPropertyPlaybackQueueCount];
	[[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:trackInfo];
}

- (BOOL)isNowPlayingItem:(id<SFMediaItem>)mediaItem {
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

- (BOOL)canHandleRemoteControlEvents {
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

- (void)handleRemoteControlEvent:(UIEvent *)event {
	if(event.type != UIEventTypeRemoteControl) {
		NSLog(@"Discarding remote control event of unkown type %d", event.type);
		return;
	}
	
	switch(event.subtype) {
		case UIEventSubtypeRemoteControlPlay:
			[self resumePlayback];
			break;
		case UIEventSubtypeRemoteControlPause:
		case UIEventSubtypeRemoteControlStop:
			[self pausePlayback];
			break;
		case UIEventSubtypeRemoteControlTogglePlayPause:
			[self togglePlayback];
			break;
		case UIEventSubtypeRemoteControlPreviousTrack:
			[self skipToPrevousItem];
			break;
		case UIEventSubtypeRemoteControlNextTrack:
			[self skipToNextItem];
			break;			
		default:
			NSLog(@"Received unknown remote control event subtype: %d", event.subtype);
			break;
	}
}

- (void)enableAudioSessionWithCategory:(NSString *)category {
	NSLog(@"Enabling audio session for category:%@", category);
	AVAudioSession *session = [AVAudioSession sharedInstance];
	session.delegate = self;
	NSError *error = nil;
	if([session setCategory:category error:&error] == NO ||
	   [session setActive:YES error:&error] == NO) {
		NSLog(@"Error while enabling audio session: %@", error);
		return;
	}
	[self addRouteChangeListener];
}

- (void)disableAudioSession {
	NSLog(@"Disabling audio session");
	[self removeRouteChangeListener];
	AVAudioSession *session = [AVAudioSession sharedInstance];
	NSError *error = nil;
	if(![session setActive:NO error:&error]) {
		NSLog(@"Error: %@", error);
	}
}

- (void)addRouteChangeListener {
	AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, &AudioRouteChagneListener, (__bridge void *)(self));
}

- (void)removeRouteChangeListener {
	AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_AudioRouteChange, &AudioRouteChagneListener, (__bridge void *)(self));
}

- (void)handleAudioRouteChange:(NSDictionary *)change {
	NSUInteger reason = [[change objectForKey:(NSString *)kAudioSession_RouteChangeKey_Reason] unsignedIntegerValue];
	if(reason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
		[self pausePlayback];
	}
}

#pragma mark - AVAudioSessionDelegate

- (void)beginInterruption {
	[self removeRouteChangeListener];
}

- (void)endInterruption {
	[self addRouteChangeListener];	
}

@end


// 
//  PlaylistEntryDTO.m
//  Sonarflow
//
//  Created by Raphael Charwot on 27.10.10.
//  Copyright 2010 Charwot. All rights reserved.
//

#import "PlaylistEntryDTO.h"

#import <MediaPlayer/MediaPlayer.h>
#import "PlaylistDTO.h"
#import "TrackComparator.h"
#import "SFNativeMediaPlayer.h"

@interface PlaylistEntryDTO ()

- (void)fetchMediaItem;

@end

@implementation PlaylistEntryDTO

@dynamic mediaItemId;
@dynamic name;
@dynamic artist;
@dynamic album;
@dynamic duration;
@dynamic order;
@dynamic playlist;


- (id)key {
	return self.order;
}

- (NSArray *)keyPath {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSArray *)children {
	return nil;
}

- (NSString *)artistName {
	return self.artist;
}

- (NSString *)albumName {
	return self.album;
}

- (NSString *)albumArtistName {
	return [self artistName];
}

- (id<SFMediaItem>)parent {
	//TODO: Implement or remove "parent" from SFMediaItem
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (BOOL)mayHaveChildren {
	return NO;
}

- (BOOL)showAsBubble {
	return NO;
}

- (BOOL)hasDetailViewController {
	return NO;
}

- (BOOL)mayHaveImage {
	return NO;
}

- (void)startPlayback {
	[self.playlist.player playMediaItem:self];
}

- (NSComparisonResult)compareKeys:(id<SFMediaItem>)other {
	return [self.key compare:other.key];
}

- (NSUInteger)numTracks {
	return 1;
}

- (NSArray *)tracks {
	return [NSArray arrayWithObject:self];
}

- (MPMediaItem *)mediaItem {
	if(mediaItem == nil) {
		[self fetchMediaItem];
	}
	return mediaItem;
}

- (void)fetchMediaItem {
	MPMediaPropertyPredicate *itemPredicate =
	[MPMediaPropertyPredicate predicateWithValue:self.mediaItemId
									 forProperty:MPMediaItemPropertyPersistentID];
	
	MPMediaQuery *query = [[MPMediaQuery alloc] init];
	[query addFilterPredicate:itemPredicate];
	NSArray *tempItems = [query items];
	
	if([tempItems count] == 0) {
        NSLog(@"Item query returned no results");
	}
	
	if([tempItems count] > 1) {
		NSLog(@"Item query returned multiple results");
	}
	
	mediaItem = [tempItems lastObject];
}

- (BOOL)isEquivalentToAudioTrack:(id<SFAudioTrack>)otherTrack {
	if([otherTrack conformsToProtocol:@protocol(SFNativeTrack)] == NO) {
		return NO;
	}
	
	return [TrackComparator isTrack:self equalToTrack:(id<SFNativeTrack>)otherTrack]; 
}

@end

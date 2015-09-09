//
//  History.m
//  Sonarflow
//
//  Created by Raphael Charwot on 13.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import "History.h"
#import "PersistentStore.h"
#import "SFNativeTrack.h"
#import "PlaylistDTO.h"
#import "PlaylistEntryDTO.h"
#import "SFNativeMediaPlayer.h"

@interface History ()

@property (nonatomic, readwrite, strong) NSArray *children;

@end

@implementation History {
	@private
	NSUInteger maxSize;
	PersistentStore *store;
	SFNativeMediaPlayer *player;
	
	PlaylistDTO *historyPlaylist;
	NSMutableArray *children;
}


- (id)initWithMaxSize:(NSUInteger)theMaxSize
				store:(PersistentStore *)theStore
			   player:(SFNativeMediaPlayer *)thePlayer {
	self = [super init];
	if(self) {
		maxSize = theMaxSize;
		store = theStore;
		player = thePlayer;
		historyPlaylist = [store historyPlaylist];
		historyPlaylist.player = player;
		[self fetchStoredEntries];
	}
	return self;
}


@synthesize children;

- (id)key {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSArray *)keyPath {
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

- (void)insertChildren:(NSArray *)newChildren atIndexes:(NSIndexSet *)indexes {
	[children insertObjects:newChildren atIndexes:indexes];
}

- (void)removeChildrenAtIndexes:(NSIndexSet *)indexes {
	[children removeObjectsAtIndexes:indexes];
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

- (void)fetchStoredEntries {
	self.children = [[historyPlaylist sortedEntries] mutableCopy];
}

- (void)nowPlayingTrackChanged:(NSObject<SFNativeTrack> *)track {
	if([self previousTrackIsDifferentFromTrack:track]) {
		[self addTrack:track];
	}
}

- (BOOL)previousTrackIsDifferentFromTrack:(NSObject<SFNativeTrack> *)newTrack {
	if(newTrack == nil) {
		return NO;
	}
	
	if([self.children count] == 0) {
		return YES;
	}
	
	if([[self previousEntry] isEquivalentToAudioTrack:newTrack]) {
		return NO;
	}
	
	return YES;
}

- (PlaylistEntryDTO *)previousEntry {
	if([self.children count] == 0) {
		return nil;
	}
	return [self.children objectAtIndex:0];
}

- (void)addTrack:(NSObject<SFNativeTrack> *)track {
	PlaylistEntryDTO *entry = [store addEntryFromTrack:track];

	PlaylistEntryDTO *previous = [self previousEntry];
	entry.order = [NSNumber numberWithInteger:[previous.order integerValue] - 1];
	entry.playlist = historyPlaylist;
	
	[self insertEntry:entry];
	[self trimOldItems];
	[store save];
}

- (void)insertEntry:(PlaylistEntryDTO *)entry {
	NSUInteger insertionIndex = 0;
	NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:insertionIndex];
	[self insertChildren:[NSArray arrayWithObject:entry] atIndexes:indexes];
	[historyPlaylist addEntriesObject:entry];
}

- (void)trimOldItems {
	if([self numTracks] > maxSize) {
		[self removeEntriesInRange:NSMakeRange(maxSize, [self numTracks] - maxSize)];
	}
}

- (void)removeEntriesInRange:(NSRange)range {
	NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:range];
	NSArray *removed = [self.children objectsAtIndexes:indexes];

	NSSet *set = [[NSSet alloc] initWithArray:removed];
	[historyPlaylist removeEntries:set];
	[self removeChildrenAtIndexes:indexes];
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
	return NSLocalizedString(@"History",
							 @"Title for playlist of previously playing tracks");
}

@end

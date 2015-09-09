//
//  PlaylistEditorImpl.m
//  Sonarflow
//
//  Created by Raphael Charwot on 12.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import "PlaylistEditorImpl.h"
#import "SFMediaLibrary.h"
#import "SFMediaPlayer.h"
#import "CollectionMenuController.h"
#import "SFPlaylist.h"
#import "AppFactory.h"
#import "SFArrayObserver.h"

@interface PlaylistEditorImpl () <SFArrayObserverDelegate>

@property (weak, nonatomic, readonly) CollectionMenuController *menuController;
@property (weak, nonatomic, readonly) PlaylistPicker *playlistPicker;
@property (nonatomic, strong) NSObject<SFMediaItem> *selectedMediaItem;
@property (nonatomic, strong) NSObject<SFPlaylist> *previousPlaylist;

@end


@implementation PlaylistEditorImpl {
	NSObject<SFMediaLibrary> *library;
	AppFactory *factory;
	SFArrayObserver *playlistsObserver;
	
	CollectionMenuController *menuController;
	PlaylistPicker *playlistPicker;
}


- (id)initWithLibrary:(NSObject<SFMediaLibrary> *)theLibrary
			  factory:(AppFactory *)theFactory {
	self = [super init];
	if(self) {
		library = theLibrary;
		factory = theFactory;
		playlistsObserver = [[SFArrayObserver alloc] initWithObject:library keyPath:@"playlists" delegate:self];
	}
	return self;
}


@synthesize delegate;
@synthesize selectedMediaItem;
@synthesize previousPlaylist;
- (void)setPreviousPlaylist:(NSObject<SFPlaylist> *)thePreviousPlaylist {
	if(previousPlaylist == thePreviousPlaylist) {
		return;
	}
	previousPlaylist = thePreviousPlaylist;
	self.menuController.previousPlaylistTitle = [previousPlaylist name];
}

- (void)attachToView:(UIView *)view delegate:(id<MenuTargetDelegate>)menuTargetDelegate {
	[self.menuController attachToView:view delegate:menuTargetDelegate];
}

- (void)detachFromView:(UIView *)view {
	[self.menuController detachFromView:view];
}

- (CollectionMenuController *)menuController {
	if(menuController == nil) {
		[self createMenuController];
	}
	
	return menuController;
}

- (void)createMenuController {
	menuController = [factory newMenuController];
	menuController.delegate = self;
}

- (void)selectPlaylistForMediaItem:(id<SFMediaItem>)mediaItem {
	self.selectedMediaItem = mediaItem;
	[self presentPlaylistPickerForMediaItem:mediaItem];
}

- (void)presentPlaylistPickerForMediaItem:(id<SFMediaItem>)mediaItem {
	[self updatePlaylistPickerPromptForMediaItem:mediaItem];
	[self.delegate presentPlaylistPicker:self.playlistPicker];
}

- (void)updatePlaylistPickerPromptForMediaItem:(id<SFMediaItem>)mediaItem {
	NSString *promptFormat = NSLocalizedString(@"Select a playlist for %@",
											   @"Prompt for picking a playlist for adding a media item");
	NSString *prompt = [NSString stringWithFormat:promptFormat, mediaItem.name];
	[self.playlistPicker setPrompt:prompt];
}

- (PlaylistPicker *)playlistPicker {
	if(playlistPicker == nil) {
		[self createPlaylistPicker];
	}
	return playlistPicker;
}

- (void)createPlaylistPicker {
	playlistPicker = [factory playlistPicker];
	playlistPicker.playlistDelegate = self;
}

- (void)extendPreviouslySelectedPlaylistByMediaItem:(id<SFMediaItem>)mediaItem {
	[self.previousPlaylist addMediaItem:mediaItem];
}

#pragma mark - PlaylistPickerDelegate

- (void)pickedPlaylist:(NSObject<SFPlaylist> *)playlist {
	self.previousPlaylist = playlist;
	[self.playlistPicker dismissModalViewControllerAnimated:YES];
	[self extendPreviouslySelectedPlaylistByMediaItem:self.selectedMediaItem];
}

#pragma mark - SFArrayObserverDelegate

- (void)object:(NSObject *)object wasSetFrom:(id)oldValue to:(id)newValue {
	self.previousPlaylist = nil;
}

- (void)objects:(NSArray *)objects wereDeletedAtIndexes:(NSIndexSet *)indexes ofObject:(NSObject *)object {
	[self resetPreviousPlaylistIfContainedIn:objects];
}

- (void)objects:(NSArray *)oldObjects wereReplacedWithObjects:(NSArray *)newObjects atIndexes:(NSIndexSet *)indexes ofObject:(NSObject *)object {
	[self resetPreviousPlaylistIfContainedIn:oldObjects];
}

- (void)resetPreviousPlaylistIfContainedIn:(NSArray *)playlists {
	if(self.previousPlaylist != nil && [playlists containsObject:self.previousPlaylist]) {
		self.previousPlaylist = nil;
	}	
}

@end

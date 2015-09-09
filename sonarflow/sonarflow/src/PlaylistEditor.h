//
//  PlaylistEditor.h
//  Sonarflow
//
//  Created by Raphael Charwot on 12.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFPlaylist;
@protocol MenuTargetDelegate;
@protocol PlaylistEditorDelegate;
@protocol SFMediaItem;

@class PlaylistPicker;

@protocol PlaylistEditor

@property (nonatomic, weak) id<PlaylistEditorDelegate> delegate;

- (void)attachToView:(UIView *)view delegate:(id<MenuTargetDelegate>)menuTargetDelegate;
- (void)detachFromView:(UIView *)view;

- (void)setPreviousPlaylist:(NSObject<SFPlaylist> *)playlist;

- (void)selectPlaylistForMediaItem:(id<SFMediaItem>)mediaItem;
- (void)extendPreviouslySelectedPlaylistByMediaItem:(id<SFMediaItem>)mediaItem;

@end

@protocol PlaylistEditorDelegate

- (void)presentPlaylistPicker:(PlaylistPicker *)picker;

@end


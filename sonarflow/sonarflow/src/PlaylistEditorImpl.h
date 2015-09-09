//
//  PlaylistEditorImpl.h
//  Sonarflow
//
//  Created by Raphael Charwot on 12.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlaylistEditor.h"
#import "PlaylistPicker.h"
#import "CollectionMenuController.h"

@protocol SFMediaLibrary;
@protocol SFPlaylist;
@class AppFactory;

@interface PlaylistEditorImpl : NSObject
		<PlaylistEditor, PlaylistPickerDelegate, CollectionMenuControllerDelegate>

- (id)initWithLibrary:(NSObject<SFMediaLibrary> *)theLibrary
			  factory:(AppFactory *)theFactory;
@end

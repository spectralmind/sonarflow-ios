//
//  PersistentStore.h
//  Sonarflow
//
//  Created by Raphael Charwot on 13.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol SFNativeTrack;
@class PlaylistDTO;
@class PlaylistEntryDTO;

@interface PersistentStore : NSObject {
	@private
	NSManagedObjectContext *context;
	NSPredicate *typePredicate;
}

- (id)initWithContext:(NSManagedObjectContext *)theContext;

- (void)save;

- (NSArray *)playlists;
- (PlaylistDTO *)addPlaylist;
- (void)deletePlaylist:(PlaylistDTO *)playlist;

- (PlaylistEntryDTO *)addEntry;
- (PlaylistEntryDTO *)addEntryFromTrack:(id<SFNativeTrack>)track;
- (void)deleteEntry:(PlaylistEntryDTO *)entry;

- (PlaylistDTO *)historyPlaylist;

@end

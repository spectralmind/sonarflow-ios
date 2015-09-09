//
//  PersistentStore.m
//  Sonarflow
//
//  Created by Raphael Charwot on 13.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import "PersistentStore.h"
#import "SFNativeTrack.h"
#import "PlaylistDTO.h"
#import "PlaylistEntryDTO.h"

@interface PersistentStore ()

- (NSArray *)fetchPlaylistsOfType:(enum PlaylistType)type;
- (PlaylistDTO *)addHistoryPlaylist;

@end


@implementation PersistentStore

- (id)initWithContext:(NSManagedObjectContext *)theContext {
	if(self = [super init]) {
		context = theContext;
		typePredicate = [NSPredicate predicateWithFormat:@"type = $TYPE"];
	}
	return self;
}


- (void)save {
    NSError *error = nil;
	if([context hasChanges] && ![context save:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	} 
}

- (NSArray *)playlists {
	return [self fetchPlaylistsOfType:PlaylistTypeNormal];
}

- (NSArray *)fetchPlaylistsOfType:(enum PlaylistType)type {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription
								   entityForName:@"Playlist"
								   inManagedObjectContext:context];
	[request setEntity:entity];
	
	NSDictionary *subsitution = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:type]
															forKey:@"TYPE"];
	[request setPredicate:[typePredicate predicateWithSubstitutionVariables:subsitution]];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order"
																   ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];
	
	NSError *error;
	NSArray *fetchResults = [context executeFetchRequest:request error:&error];
	if(fetchResults == nil) {
		NSLog(@"Couldn't load playlists");
		//TODO: Inform the user?
	}
	
	return fetchResults;
}

- (PlaylistDTO *)addPlaylist {
	return [NSEntityDescription insertNewObjectForEntityForName:@"Playlist"
										 inManagedObjectContext:context];
}

- (void)deletePlaylist:(PlaylistDTO *)playlist {
	[context deleteObject:playlist];
}

- (PlaylistEntryDTO *)addEntry {
	return [NSEntityDescription insertNewObjectForEntityForName:@"PlaylistEntry"
										 inManagedObjectContext:context];	
}

- (PlaylistEntryDTO *)addEntryFromTrack:(id<SFNativeTrack>)track {
	PlaylistEntryDTO *entry = [self addEntry];
	entry.mediaItemId = [track mediaItemId];
	entry.name = [track name];
	entry.artist = [track artistName];
	entry.album = [track albumName];
	entry.duration = [track duration];

	if(entry.artist == nil) {
		entry.artist = @"";
	}
	if(entry.album == nil) {
		entry.album = @"";
	}

	return entry;
}

- (void)deleteEntry:(PlaylistEntryDTO *)entry {
	[context deleteObject:entry];
}

- (PlaylistDTO *)historyPlaylist {
	NSArray *historyLists = [self fetchPlaylistsOfType:PlaylistTypeHistory];
	if([historyLists count] == 0) {
		return [self addHistoryPlaylist];
	}
	else if([historyLists count] > 1) {
		for(int i = 1; i < [historyLists count]; ++i) {
			[self deletePlaylist:[historyLists objectAtIndex:i]];
		}
	}
	
	return [historyLists objectAtIndex:0];
}

- (PlaylistDTO *)addHistoryPlaylist {
	PlaylistDTO *history = [self addPlaylist];
	history.name = @"HISTORY";
	history.type = [NSNumber numberWithInt:PlaylistTypeHistory];
	return history;
}

@end

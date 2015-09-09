//
//  PlaylistEntryDTO.h
//  Sonarflow
//
//  Created by Raphael Charwot on 27.10.10.
//  Copyright 2010 Charwot. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SFNativeTrack.h"

@class PlaylistDTO;

@interface PlaylistEntryDTO :  NSManagedObject <SFNativeTrack> {
	MPMediaItem *mediaItem;
}

@property (nonatomic, strong) NSNumber *mediaItemId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *album;
@property (nonatomic, strong) NSNumber *duration;
@property (nonatomic, strong) NSNumber *order;
@property (nonatomic, strong) PlaylistDTO *playlist;

@end

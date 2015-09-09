//
//  PlaylistDTO.h
//  Sonarflow
//
//  Created by Raphael Charwot on 27.10.10.
//  Copyright 2010 Charwot. All rights reserved.
//

#import <CoreData/CoreData.h>

@class SFNativeMediaPlayer;

enum PlaylistType {
	PlaylistTypeNormal,
	PlaylistTypeHistory
};

@interface PlaylistDTO : NSManagedObject {
}

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * type;
@property (nonatomic, strong) NSNumber * order;
@property (nonatomic, strong) NSSet* entries;

@property (nonatomic, weak) SFNativeMediaPlayer *player;

- (NSArray *)sortedEntries;

@end


@interface PlaylistDTO (CoreDataGeneratedAccessors)
- (void)addEntriesObject:(NSManagedObject *)value;
- (void)removeEntriesObject:(NSManagedObject *)value;
- (void)addEntries:(NSSet *)value;
- (void)removeEntries:(NSSet *)value;

@end


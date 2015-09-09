//
//  History.h
//  Sonarflow
//
//  Created by Raphael Charwot on 13.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFPlaylist.h"
#import "SFNativeMediaItem.h"

@protocol SFNativeTrack;
@class PersistentStore;
@class SFNativeMediaPlayer;

@interface History : NSObject <SFPlaylist, SFNativeMediaItem>

@property (nonatomic, readonly, strong) NSArray *tracks;

- (id)initWithMaxSize:(NSUInteger)theMaxSize
				store:(PersistentStore *)theStore
			   player:(SFNativeMediaPlayer *)thePlayer;
			  
- (void)nowPlayingTrackChanged:(NSObject<SFNativeTrack> *)track;

@end

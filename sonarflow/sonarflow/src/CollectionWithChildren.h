//
//  CollectionWithChildren.h
//  Sonarflow
//
//  Created by Raphael Charwot on 02.03.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMediaCollection.h"

@class SFTrack;

@interface CollectionWithChildren : SFMediaCollection

@property (weak, nonatomic, readonly) NSMutableArray *tempTracks;
@property (nonatomic, assign) NSUInteger numTracks;
@property (nonatomic, strong) NSArray *children;

- (void)addTrack:(SFTrack *)track;
- (void)releaseLocalTracks;
- (BOOL)hasReceivedAllTracks;

- (void)addChildrenInMainThread:(NSArray *)newChildren;

//Pure virtual
- (NSArray *)sortTracks:(NSArray *)tracks;
- (NSArray *)sortChildren:(NSArray *)children;

@end

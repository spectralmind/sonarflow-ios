//
//  TrackComparator.m
//  sonarflow
//
//  Created by Raphael Charwot on 09.09.11.
//  Copyright (c) 2011 Charwot. All rights reserved.
//

#import "TrackComparator.h"
#import "SFNativeTrack.h"

@implementation TrackComparator

+ (BOOL)isTrack:(id<SFNativeTrack>)first equalToTrack:(id<SFNativeTrack>)second {
	NSNumber *firstId = [first mediaItemId];
	NSNumber *secondId = [second mediaItemId];
	return [firstId unsignedLongLongValue] == [secondId unsignedLongLongValue];
}

@end

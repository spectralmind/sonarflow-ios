//
//  TrackComparator.h
//  sonarflow
//
//  Created by Raphael Charwot on 09.09.11.
//  Copyright (c) 2011 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SFNativeTrack;

@interface TrackComparator : NSObject

+ (BOOL)isTrack:(id<SFNativeTrack>)first equalToTrack:(id<SFNativeTrack>)second;

@end

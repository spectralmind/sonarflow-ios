//
//  MPVolumeView+AirPlay.m
//  sonarflow
//
//  Created by Raphael Charwot on 28.03.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import "MPVolumeView+AirPlay.h"

@implementation MPVolumeView (AirPlay)

- (BOOL)supportsAirPlay {
	return [self respondsToSelector:@selector(showsRouteButton)];
}

@end

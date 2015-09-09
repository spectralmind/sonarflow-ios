//
//  Formatter.m
//  Sonarflow
//
//  Created by Raphael Charwot on 05.11.10.
//  Copyright 2010 Charwot. All rights reserved.
//

#import "Formatter.h"


@implementation Formatter

+ (NSString *)formatDuration:(NSTimeInterval)duration {
	unsigned long seconds = duration;
	unsigned long minutes = seconds / 60;
	seconds %= 60;
	unsigned long hours = minutes / 60;
	minutes %= 60;
	
	if(hours > 0) {
		return [NSString stringWithFormat:@"%lu:%02lu:%02lu", hours, minutes, seconds];
	}
	
	return [NSString stringWithFormat:@"%lu:%02lu", minutes, seconds];
}

@end

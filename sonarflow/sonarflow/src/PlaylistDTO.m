// 
//  PlaylistDTO.m
//  Sonarflow
//
//  Created by Raphael Charwot on 27.10.10.
//  Copyright 2010 Charwot. All rights reserved.
//

#import "PlaylistDTO.h"
#import "PlaylistEntryDTO.h"

@implementation PlaylistDTO

@dynamic name;
@dynamic type;
@dynamic order;
@dynamic entries;
@synthesize player;

- (NSArray *)sortedEntries {
	NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"key" ascending:YES];
	return [self.entries sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
}

@end

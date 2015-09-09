//
//  DiscoveryZone.m
//  bubbleview
//
//  Created by Arvid Staub on 27.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DiscoveryZone.h"
#import "DiscoveryZoneMember.h"

@implementation DiscoveryZone {
	NSArray *members;
	CGPoint center;
	CGFloat radius;
}

@synthesize members;
@synthesize center;
@synthesize radius;


- (NSString *)description {
	NSMutableString *string = [NSMutableString string];
	[string appendString:@"zone: {"];
	
	for(DiscoveryZoneMember *member in self.members) {
		[string appendFormat:@"'%@' ", member.keyPath.lastObject];
	}
	
	[string appendString:@"}"];
	return string;
}

@end

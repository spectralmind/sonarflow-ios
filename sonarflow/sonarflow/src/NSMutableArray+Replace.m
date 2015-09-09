//
//  NSMutableArray+Replace.m
//  Sonarflow
//
//  Created by Raphael Charwot on 06.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import "NSMutableArray+Replace.h"


@implementation NSMutableArray (Replace)

- (void)replace:(NSObject *)original with:(NSObject *)replacement {
	NSUInteger indexOfOriginal = [self indexOfObject:original];
	if(indexOfOriginal != NSNotFound) {
		[self replaceObjectAtIndex:indexOfOriginal withObject:replacement];
	}
}

@end

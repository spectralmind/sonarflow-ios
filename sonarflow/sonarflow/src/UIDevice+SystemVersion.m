//
//  UIDevice+SystemVersion.m
//  sonarflow
//
//  Created by Charwot Raphael on 29.02.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "UIDevice+SystemVersion.h"

@implementation UIDevice (SystemVersion)

+ (BOOL)isSystemVersionLessThan5 {
	return [[[self currentDevice] systemVersion] compare:@"5.0" options:NSNumericSearch] == NSOrderedAscending;
}

@end

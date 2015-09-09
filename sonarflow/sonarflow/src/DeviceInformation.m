//
//  DeviceInformation.m
//  sonarflow
//
//  Created by Raphael Charwot on 12.09.11.
//  Copyright (c) 2011 Charwot. All rights reserved.
//

#import "DeviceInformation.h"

@implementation DeviceInformation

+ (BOOL)isRunningOnOSVersion5OrNewer {
	return [[NSFileManager defaultManager] respondsToSelector:@selector(isUbiquitousItemAtURL:)];
}

@end

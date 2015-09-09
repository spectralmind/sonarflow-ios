//
//  NSString+DocumentsPath.m
//  Common Code
//
//  Created by Raphael Charwot on 09.10.09.
//  Copyright 2009 Charwot. All rights reserved.
//

#import "NSString+DocumentsPath.h"


@implementation NSString(DocumentsPath)

+ (NSString *)pathForDocumentFile:(NSString *)fileName {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:fileName];
}

@end

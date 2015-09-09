//
//  SMResultCache.m
//  SMArtist
//
//  Created by Manuel Maly on 13.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>

#import "SMResultCache.h"
#import "SMArtistResult.h"
#import "SMArtistResult+Private.h"

#define CACHE_SUBDIRECTORY @"smartist"
#define CACHE_FILE_SUFFIX @"smart"


@implementation SMResultCache {
	@private
	NSTimeInterval maximumAge;
	NSString *cachePath;
}

- (id)initWithMaximumAge:(NSTimeInterval)theMaximumAge {
    self = [super init];
    if (self) {
		maximumAge = theMaximumAge;

		if([self prepareCachePath] == NO) {
			return nil;
		};
    }
    return self;
}


- (BOOL)prepareCachePath {
	NSString *cacheBase = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
	cachePath = [cacheBase stringByAppendingPathComponent:CACHE_SUBDIRECTORY];
	return [self createCachePath];
}


- (BOOL)createCachePath {
	NSError *error;
	BOOL ok = [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES 
		attributes:nil error:&error];
	if(ok == NO) {
		NSLog(@"error: could not create cache path at %@: %@",cachePath,error);
		return NO;
	}
	return YES;
}

- (SMArtistResult *)resultForCacheId:(NSString *)cacheId {
 	return [self resultForCacheId:cacheId allowExpired:NO];
}

- (SMArtistResult *)resultForCacheId:(NSString *)cacheId allowExpired:(BOOL)expiredOk {
	if(expiredOk == NO && [self containsResultForId:cacheId] == NO) {
		return nil;
    }	

	NSString *fileFullPath = [self pathForId:cacheId];
	SMArtistResult *result = [NSKeyedUnarchiver unarchiveObjectWithFile:fileFullPath];
	result.cacheable = NO;
	return result;
}

- (BOOL)containsResultForId:(NSString *)cacheId {
    NSString *fileFullPath = [self pathForId:cacheId];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:fileFullPath] == NO) {
		return NO;
	}
	
	return [self isCacheFileExpired:fileFullPath] == NO;
}

- (BOOL)isCacheFileExpired:(NSString *)filePath {
	NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
	NSDate *lastModification = [dict objectForKey:NSFileModificationDate];
	NSTimeInterval objectAge = -[lastModification timeIntervalSinceNow];
	return objectAge > maximumAge;
}

- (void)storeResult:(SMArtistResult *)result forCacheId:(NSString *)cacheId {
    NSString *fileFullPath = [self pathForId:cacheId];
    [NSKeyedArchiver archiveRootObject:result toFile:fileFullPath];
}

- (BOOL)removeResultForCacheId:(NSString *)cacheId {
	NSString *filePath = [self pathForId:cacheId];
	BOOL success = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
	return success;
}

- (NSString *)pathForId:(NSString *)cacheId {
    NSString *fileNameWithExtension = [[self hashForCacheId:cacheId] stringByAppendingPathExtension:CACHE_FILE_SUFFIX];
    return [cachePath stringByAppendingPathComponent:fileNameWithExtension];
}

- (NSString *)hashForCacheId:(NSString *)cacheId {
    const char *cstr = [cacheId cStringUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    int length = strlen(cstr);	
    CC_SHA1(cstr, length, digest);
	
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
	}
    
    return output;
}


- (void)pruneExpired {
    NSDirectoryEnumerator *en = [[NSFileManager defaultManager] enumeratorAtPath:cachePath];
    
    NSString* relativeFilePath;
    while(relativeFilePath = [en nextObject]) {
		[self removeCacheFileIfExpired:relativeFilePath];
    }
}

- (void)removeCacheFileIfExpired:(NSString *)relativeFilePath {
	if([relativeFilePath hasSuffix:CACHE_FILE_SUFFIX] == NO) {
		return;
	}

	NSString *filePath = [cachePath stringByAppendingPathComponent:relativeFilePath];

	if([self isCacheFileExpired:filePath] == NO) {
		return;
	}
	
	NSError *err = nil;
	BOOL success = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&err];
	
	if(success == NO) {
		NSLog(@"Failed to remove cache file: %@", err);
	}
}

- (void)clear {
	NSError *err = nil;
	BOOL success = [[NSFileManager defaultManager] removeItemAtPath:cachePath error:&err];
	if(success == NO) {
		NSLog(@"Failed to remove cache directory: %@", err);
	}
	
	[self createCachePath];
}

@end

//
//  NSDictionary+SMArtist_JSON.m
//  sonarflow
//
//  Created by Fabian on 31.01.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "NSDictionary+SMArtist_JSON.h"

@implementation NSDictionary (SMArtist_JSON)

- (NSString *)sma_stringForKey:(id)key
{
    return [self sma_objectOfClass:[NSString class] forKey:key];
}


- (NSDictionary *)sma_dictionaryForKey:(id)key
{
    return [self sma_objectOfClass:[NSDictionary class] forKey:key];
}


- (NSArray *)sma_arrayForKey:(id)key
{
    return [self sma_objectOfClass:[NSArray class] forKey:key];
}


- (NSNumber *)sma_numberForKey:(id)key
{
    return [self sma_objectOfClass:[NSNumber class] forKey:key];
}


- (id)sma_objectOfClass:(Class)class forKey:(id)key
{
    id object = [self objectForKey:key];
    if ([object isKindOfClass:class]) {
		return object;
	} else {
		return nil;
	}
}


- (NSArray *)sma_makeArrayOfObjectForKey:(id)key
{
    id object = [self objectForKey:key];
	if (object == nil) {
		return nil;
	} else if ([object isKindOfClass:[NSArray class]]) {
		return object;
	} else {
		return [NSArray arrayWithObject:object];
	}
}

@end

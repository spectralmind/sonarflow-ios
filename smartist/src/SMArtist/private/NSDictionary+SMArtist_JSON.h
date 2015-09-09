//
//  NSDictionary+SMArtist_JSON.h
//  sonarflow
//
//  Created by Fabian on 31.01.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (SMArtist_JSON)

- (NSString *)sma_stringForKey:(id)key;

- (NSDictionary *)sma_dictionaryForKey:(id)key;

- (NSArray *)sma_arrayForKey:(id)key;

- (NSNumber *)sma_numberForKey:(id)key;

- (id)sma_objectOfClass:(Class)class forKey:(id)key;

- (NSArray *)sma_makeArrayOfObjectForKey:(id)key;

@end

//
//  NSString+Truncate.h
//  Sonarflow
//
//  Created by Raphael Charwot on 17.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Truncate)

- (NSString *)stringByTruncatingToLength:(NSUInteger)length;
- (NSString *)stringByTruncatingMiddleToLength:(NSUInteger)length;

@end

//
//  NSString+Truncate.m
//  Sonarflow
//
//  Created by Raphael Charwot on 17.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import "NSString+Truncate.h"


@implementation NSString (Truncate)

- (NSString *)safeSubstringWithRange:(NSRange)range {
	NSRange safeRange = [self rangeOfComposedCharacterSequencesForRange:range];
	return [self substringWithRange:safeRange];
}

- (NSString *)stringByTruncatingToLength:(NSUInteger)length {
	if([self length] <= length) {
		return self;
	}

	NSRange stringRange = {0, length - 1};
	NSString *shortString = [self safeSubstringWithRange:stringRange];
	return [shortString stringByAppendingString:@"…"];	
}

- (NSString *)stringByTruncatingMiddleToLength:(NSUInteger)length {
	if([self length] <= length) {
		return self;
	}
	
	NSUInteger headLength = length / 2 + 1;
	NSUInteger tailLength = length - headLength;
	NSRange tailRange = {[self length] - tailLength, tailLength};
	
	NSString *head = [self stringByTruncatingToLength:headLength];
	NSString *tail = [self safeSubstringWithRange:tailRange];
	
	return [head stringByAppendingString:tail];
}

@end

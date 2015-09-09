//
//  GenreDefinition.h
//  sonarflow
//
//  Created by Raphael Charwot on 07.09.11.
//  Copyright (c) 2011 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GenreDefinition : NSObject {
	@private
	NSString *name;
	CGPoint origin;
	UIColor *color;
	NSArray *subgenres;
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) CGPoint origin;
@property (nonatomic, readonly) UIColor *color;
@property (nonatomic, readonly) NSArray *subgenres;

- (id)initWithName:(NSString *)theName origin:(CGPoint)theOrigin color:(UIColor *)theColor subgenres:(NSArray *)theSubgenres;

- (BOOL)containsGenreName:(NSString *)genreName;

@end

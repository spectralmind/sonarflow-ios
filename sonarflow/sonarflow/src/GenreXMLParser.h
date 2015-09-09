//
//  GenreXMLParser.h
//  Sonarflow
//
//  Created by Vinzenz-Emanuel Weber on 08.07.10.
//  Copyright 2010 techforce.at. All rights reserved.
//


#import <Foundation/Foundation.h>

@class GenreDefinition;
@protocol GenreParserDelegate;


@interface GenreXMLParser : NSObject <NSXMLParserDelegate> {
	@private
	NSString *name;
	CGPoint origin;
	UIColor *color;
	NSArray *subgenres;

	NSMutableArray *genres;
	NSMutableString *currentItemValue;
	
	BOOL flipAxes;
}

- (id)initWithFlipAxes:(BOOL)flip;

@property(nonatomic, strong, readonly) NSArray *genres;

-(BOOL)parse;

@end
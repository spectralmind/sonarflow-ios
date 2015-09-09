//
//  GenreXMLParser.m
//  Sonarflow
//
//  Created by Vinzenz-Emanuel Weber on 08.07.10.
//  Copyright 2010 techforce.at. All rights reserved.
//

#import "GenreXMLParser.h"
#import "GenreDefinition.h"

@interface GenreXMLParser ()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSArray *subgenres;
@property(nonatomic, strong, readwrite) NSArray *genres;
@property(nonatomic, strong) NSMutableString *currentItemValue;

@end

@implementation GenreXMLParser

@synthesize name;
@synthesize origin;
@synthesize color;
@synthesize subgenres;
@synthesize genres;
@synthesize currentItemValue;

- (id)initWithFlipAxes:(BOOL)flip {
    self = [super init];
    if (self) {
		flipAxes = flip;
    }
    return self;
}


-(BOOL)parse {
	self.genres = [NSMutableArray array];
	BOOL success = NO;

	// parse xml genre file
	NSString *localXMLFilePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"genres.xml"];
	if([[NSFileManager defaultManager] fileExistsAtPath:localXMLFilePath]) {
		NSData *xmlData = [[NSData alloc] initWithContentsOfFile:localXMLFilePath];
		if(xmlData == nil) {
			NSLog(@"error occured while loading xml from file");
		}
		else {
			@autoreleasepool {
				NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
				[parser setDelegate:self];
				[parser setShouldProcessNamespaces:YES];
				[parser setShouldReportNamespacePrefixes:YES];
				[parser setShouldResolveExternalEntities:NO];
				success = [parser parse];
			}
		}
	}

	return success;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict{
	if(nil != qualifiedName) {
		elementName = qualifiedName;
	}
	
	if([elementName isEqualToString:@"name"] || 
			[elementName isEqualToString:@"subgenres"] ||
			[elementName isEqualToString:@"x"] ||
			[elementName isEqualToString:@"y"] ||
			[elementName isEqualToString:@"color"]) {
		self.currentItemValue = [NSMutableString string];
	}
	else {
		self.currentItemValue = nil;
	}
}


#define HEXCOLOR(c) 


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if(nil != qName) {
		elementName = qName;
	}

	NSString *value = [self.currentItemValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

	if([elementName isEqualToString:@"name"]) {
		self.name = value;
	}
	else if([elementName isEqualToString:@"subgenres"]) {
		self.subgenres = [value componentsSeparatedByString:@","];
	}
	else if([elementName isEqualToString:@"x"]) {
		self.origin = CGPointMake([value intValue], self.origin.y);
	}
	else if([elementName isEqualToString:@"y"]) {
		self.origin = CGPointMake(self.origin.x, [value intValue]);
	}
	else if([elementName isEqualToString:@"color"]) {
		unsigned int colorValue;
		[[NSScanner scannerWithString:value] scanHexInt:&colorValue];
		self.color = [UIColor colorWithRed:((colorValue>>16)&0xFF)/255.0 \
												  green:((colorValue>>8)&0xFF)/255.0 \
												   blue:((colorValue)&0xFF)/255.0 \
												  alpha:1.0f];
	}
	else if([elementName isEqualToString:@"genre"]) {
		if(flipAxes) {
			self.origin = CGPointMake(-self.origin.y, -self.origin.x);
		}
		GenreDefinition *genreDefinition = [[GenreDefinition alloc] initWithName:self.name origin:self.origin color:self.color subgenres:self.subgenres];
		[genres addObject:genreDefinition];
		self.name = nil;
		self.subgenres = nil;
		self.origin = CGPointZero;
		self.color = nil;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if(nil != self.currentItemValue) {
		[self.currentItemValue appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
	if(nil != self.currentItemValue) {
		NSString *asciiString = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
		[self.currentItemValue appendString:asciiString];
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
	if(parseError.code != NSXMLParserDelegateAbortedParseError) {
		NSLog(@"parseError code: %i", [parseError code]);

		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"XML Error" message:[NSString stringWithFormat:@"Genre XML Parser Error: %i",[parseError code]]
													   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
}

@end
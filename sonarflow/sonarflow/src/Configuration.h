//
//  Configuration.h
//  Sonarflow
//
//  Created by Raphael Charwot on 28.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppStatusObserver.h"

@interface Configuration : NSObject
		<AppStatusObserverDelegate> {
	AppStatusObserver *statusObserver;
	NSDictionary *developmentSettings;
}

+ (void)initWithDevelopmentSettingsPath:(NSString *)path;
+ (Configuration *)sharedConfiguration;


- (id)initWithDevelopmentSettingsPath:(NSString *)path;

- (NSString *)settingsValues;

- (NSNumber *)numberForIdentifier:(NSString *)identifier;
- (NSString *)stringForIdentifier:(NSString *)identifier;

- (CGFloat)bubbleSizeToShowChildren;
- (CGFloat)bubbleSizeToShowChildrenIphoneFactor;
- (CGFloat)bubbleSizeToShowTitle;
- (CGFloat)bubbleFadeSize;
- (CGSize)bubbleCoverSize;
- (BOOL)bubbleEnableCountDisplay;

- (NSString *)echonestApiKey;
- (NSString *)lastfmApiKey;
- (NSString *)lastfmApiSecret;

- (BOOL)genreLookupEnabled;

@end

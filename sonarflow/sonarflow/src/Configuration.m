//
//  Configuration.m
//  Sonarflow
//
//  Created by Raphael Charwot on 28.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import "Configuration.h"

@interface Configuration ()

- (void)registerDefaultsFromSettingsBundle;
- (NSBundle *)settingsBundle;
- (NSDictionary *)defaultValues;
- (NSDictionary *)defaultValuesFromFile:(NSString *)path;
- (void)loadDevelompentSettingsFromPath:(NSString *)path;
- (void)resetToDefaultsIfNecessary;
- (void)printValues;

@end

@implementation Configuration

static Configuration *sharedConfiguration;

+ (void)initWithDevelopmentSettingsPath:(NSString *)path {
	sharedConfiguration = [[self alloc] initWithDevelopmentSettingsPath:path];
}

+ (Configuration *)sharedConfiguration {
	return sharedConfiguration;
}

- (id)initWithDevelopmentSettingsPath:(NSString *)path {
	self = [super init];
	if(self) {
		statusObserver = [[AppStatusObserver alloc] initWithBecomeActiveDelay:0];
		[statusObserver setDelegate:self];
		
		[self registerDefaultsFromSettingsBundle];
		[self loadDevelompentSettingsFromPath:path];
		[self resetToDefaultsIfNecessary];
	}
	return self;
}

- (void)registerDefaultsFromSettingsBundle {
	NSDictionary *defaults = [self defaultValues];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (NSDictionary *)defaultValues {
	NSBundle *settingsBundle = [self settingsBundle];
	
	NSArray *plistFiles = [settingsBundle pathsForResourcesOfType:@"plist" inDirectory:nil];
	
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	for(NSString *plistPath in plistFiles) {
		NSDictionary *fileDefaults = [self defaultValuesFromFile:plistPath];
		[defaults addEntriesFromDictionary:fileDefaults];
	}
	return defaults;
}

- (NSBundle *)settingsBundle {
	NSString *settingsPath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
	if(settingsPath == nil) {
		NSLog(@"Could not find Settings.bundle");
		return nil;
	}
	return [NSBundle bundleWithPath:settingsPath];
}

- (NSDictionary *)defaultValuesFromFile:(NSString *)path {
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
	
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaults setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
	return defaults;
}

- (void)loadDevelompentSettingsFromPath:(NSString *)path {
	developmentSettings = [[NSDictionary alloc] initWithContentsOfFile:path];
	if(developmentSettings == nil) {
		NSLog(@"Could not load developmentSettings");
		abort();
	}
}

- (void)resetToDefaultsIfNecessary {
	BOOL reset = [[self numberForIdentifier:@"reset"] boolValue];
	if (reset) {
		NSDictionary *settingDefaults = [self defaultValues];
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		for(id key in settingDefaults) {
			[userDefaults removeObjectForKey:key];
		}
	}
}

- (void)printValues {
	NSDictionary *defaults = [self defaultValues];
	NSDictionary *values = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	NSLog(@"Configuration values:");
	for(id key in defaults) {
		NSLog(@"%@ = %@", key, [values objectForKey:key]);
	}
}

- (NSString *)settingsValues {
	NSMutableString *settings = [NSMutableString string];
	NSDictionary *defaults = [self defaultValues];
	NSDictionary *values = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	for(id key in defaults) {
		[settings appendFormat:@"%@ = %@\n", key, [values objectForKey:key]];
	}
	return settings;
}

- (NSNumber *)numberForIdentifier:(NSString *)identifier {
	id value = [[NSUserDefaults standardUserDefaults] valueForKey:identifier];
	if(value == nil) {
		value = [developmentSettings valueForKeyPath:identifier];
	}

	return value;
}

- (CGFloat)bubbleSizeToShowChildren {
	return [[self numberForIdentifier:@"bubbles.size_to_show_children"] floatValue];
}

- (CGFloat)bubbleSizeToShowChildrenIphoneFactor {
	return [[self numberForIdentifier:@"bubbles.size_to_show_children_iphone_factor"] floatValue];
}

- (CGFloat)bubbleSizeToShowTitle {
	return [[self numberForIdentifier:@"bubbles.size_to_show_title"] floatValue];
}

- (CGFloat)bubbleFadeSize {
	return [[self numberForIdentifier:@"bubbles.fade_size"] floatValue];
}


- (CGSize)bubbleCoverSize {
	NSInteger coverWidth = [[self numberForIdentifier:@"bubbles.cover_size"] intValue];
	return CGSizeMake(coverWidth, coverWidth);
}

- (BOOL)bubbleEnableCountDisplay {
	return [[self numberForIdentifier:@"bubbles.enable_count_display"] boolValue];
}


- (NSString *)echonestApiKey {
	return [self stringForIdentifier:@"social.echonest-api-key"];
}

- (NSString *)lastfmApiKey {
	return [self stringForIdentifier:@"social.lastfm-api-key"];
}

- (NSString *)lastfmApiSecret {
	return [self stringForIdentifier:@"social.lastfm-api-secret"];
}


- (NSString *)stringForIdentifier:(NSString *)identifier {
	id value = [[NSUserDefaults standardUserDefaults] valueForKey:identifier];
	if(value == nil) {
		value = [developmentSettings valueForKeyPath:identifier];
	}
	
	return value;
}

- (BOOL)genreLookupEnabled {
	BOOL ret = [[self numberForIdentifier:@"othercleanup"] boolValue];
	return ret;
}


#pragma mark -
#pragma mark AppStatusObserverDelegate

- (void)appWillEnterForeground {
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)appWillResignActive {
	[[NSUserDefaults standardUserDefaults] synchronize];
}


@end

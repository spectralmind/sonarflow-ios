//
//  LastfmSettings.m
//  sonarflow
//
//  Created by Raphael Charwot on 14.03.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "LastfmSettings.h"

#define kScrobble @"s"
#define kUsername @"u"
#define kPassword @"p"

@implementation LastfmSettings {
	BOOL scrobble;
	NSString *username;
	NSString *password;
}

+ (LastfmSettings *)settingsWithScrobble:(BOOL)scrobble username:(NSString *)username password:(NSString *)password {
	LastfmSettings *settings = [[LastfmSettings alloc] init];
	settings.scrobble = scrobble;
	settings.username = username;
	settings.password = password;
	return settings;
}


@synthesize scrobble;
@synthesize username;
@synthesize password;

- (id)copyWithZone:(NSZone *)zone {
	LastfmSettings *copy = [[[self class] allocWithZone:zone] init];
	copy.scrobble = self.scrobble;
	copy.username = self.username;
	copy.password = self.password;
	return copy;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Settings (scrobble:%d username:%@ password:%@)", (int)self.scrobble, self.username, self.password];
}

- (BOOL)isEqual:(id)object {
	if([object isKindOfClass:[LastfmSettings class]] == NO) {
		return NO;
	}

	LastfmSettings *other = (LastfmSettings *) object;
	return self.scrobble == other.scrobble &&
		[self.username isEqualToString:other.username] &&
		[self.password isEqualToString:other.password];
}

- (NSUInteger)hash {
	return scrobble ^ [self.username hash] ^ [self.password hash];
}

- (void) encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeBool:scrobble forKey:kScrobble];
	[encoder encodeObject:self.username forKey:kUsername];
	[encoder encodeObject:self.password forKey:kPassword];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if(nil == self) {
		return nil;
	}
	
	@try {
		self.scrobble = [decoder decodeBoolForKey:kScrobble];
		self.username = [decoder decodeObjectForKey:kUsername];		
		self.password = [decoder decodeObjectForKey:kPassword];
		return self;
	}
	@catch(NSException *ex) {
		self.username = nil;
		self.password = nil;
		
		return nil;
	}
}

@end

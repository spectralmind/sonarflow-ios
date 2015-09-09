//
//  LastfmSettings.h
//  sonarflow
//
//  Created by Raphael Charwot on 14.03.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LastfmSettings : NSObject <NSCopying>

+ (LastfmSettings *)settingsWithScrobble:(BOOL)scrobble username:(NSString *)username password:(NSString *)password;


@property (nonatomic, assign) BOOL scrobble;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

@end

//
//  GANHelper.h
//  Sonarflow
//
//  Created by Raphael Charwot on 23.11.10.
//  Copyright 2010 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Configuration;

@interface GANHelper : NSObject {
	Configuration *configuration;
	BOOL initCalled;
}

- (id)initWithConfiguration:(Configuration *)theConfiguration;

- (void)trackPageView:(NSString *)path;
- (void)trackEvent:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSInteger)value;

@end

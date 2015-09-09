//
//  GANHelper.m
//  Sonarflow
//
//  Created by Raphael Charwot on 23.11.10.
//  Copyright 2010 Charwot. All rights reserved.
//

#import "GANHelper.h"
#import "GANTracker.h"
#import "Configuration.h"

#if defined(SF_FREE)
	#define kGoogleAnalyticsAccountId @"UA-13242448-7"
#elif defined(SF_PRO)
	#define kGoogleAnalyticsAccountId @"UA-13242448-6"
#elif defined(SF_SPOTIFY)
	#define kGoogleAnalyticsAccountId @"UA-13242448-8"
#else
	#error No variant selected!
#endif

#define kGoogleAnalyticsDispatchPeriod 20

@interface GANHelper ()

- (BOOL)enabled;
- (GANTracker *)tracker;

@end


@implementation GANHelper

- (id)initWithConfiguration:(Configuration *)theConfiguration {
	if(self = [super init]) {
		configuration = theConfiguration;
	}
	return self;
}



- (void)trackPageView:(NSString *)path {
	NSError *error;
	GANTracker *tracker = [self tracker];
	if(tracker == nil) {
		return;
	}
	
//	NSLog(@"Tracking page view: %@", path);

	if(![tracker trackPageview:path
					 withError:&error]) {
		NSLog(@"GA error %d: %@", [error code], [error localizedDescription]);
	}
}

- (void)trackEvent:(NSString *)category
			action:(NSString *)action
			 label:(NSString *)label
			 value:(NSInteger)value {
	NSError *error;
	GANTracker *tracker = [self tracker];
	if(tracker == nil) {
		return;
	}
		
//	NSLog(@"Tracking event: %@ %@ %@ %d", category, action, label, value);

	if(![tracker trackEvent:category action:action label:label value:value withError:&error]) {
		NSLog(@"GA error %d: %@", [error code], [error localizedDescription]);
	}	
}

#pragma mark -
#pragma mark Private Methods

- (BOOL)enabled {
	static NSString *enabled_key = @"enable_statistics";

	return [[configuration numberForIdentifier:enabled_key] boolValue];
}

- (GANTracker *)tracker {
	if(![self enabled]) {
		return nil;
	}
	
	if(!initCalled) {
//		NSLog(@"Initializing google analytics");
		[[GANTracker sharedTracker] startTrackerWithAccountID:kGoogleAnalyticsAccountId
											   dispatchPeriod:kGoogleAnalyticsDispatchPeriod
													 delegate:nil];
		initCalled = YES;
	}
	
	return [GANTracker sharedTracker];
}


@end

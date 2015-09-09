//
//  DiscoveryResultMerger.h
//  sonarflow
//
//  Created by Arvid Staub on 26.04.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DiscoveryCoordinator.h"

@class SMArtistSimilarityResult;
@class DiscoveryZone;

@interface DiscoveryResultMerger : NSObject
@property (nonatomic, strong) DiscoveryZone *queryZone;

- (id)initWithExpectedResultCount:(int)results andDelegate:(NSObject<DiscoveryResultDelegate> *)theDelegate;
- (void)incorporateResult:(SMArtistSimilarityResult *)result;

@end

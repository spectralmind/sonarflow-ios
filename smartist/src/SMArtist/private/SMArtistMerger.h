//
//  SMArtistMerger.h
//  SMArtist
//
//  Created by Fabian on 23.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//
// ABSTRACT Manager Class
//
// Creates and manages several SMRequestable objects, merges their Results and does Caching
//

#import <Foundation/Foundation.h>
#import "SMRequestable.h"

@class SMRootFactory;
@class SMResultCache;

@interface SMArtistMerger : SMRequestable <SMRequestableDelegate>

@property (nonatomic, strong) SMArtistRequest *request;

- (id)initWithConfiguration:(SMRootFactory *)theConfigfactory withDelegate:(id<SMRequestableDelegate>)theDelegate resultClass:(id)theResultClass cache:(SMResultCache *)theCache;


@end

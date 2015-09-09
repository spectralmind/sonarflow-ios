//
//  SMWebInfoFactory.h
//  SMArtist
//
//  Created by Fabian on 06.09.11.
//  Copyright (c) 2011 Spectralmind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMArtistWebInfo.h"

@class SMSingleArtistRequest;

@class SMRootFactory;

@interface SMWebInfoFactory : NSObject

@property (nonatomic, weak) SMRootFactory *rootFactory;

- (NSArray *)webInfosWithDelegate:(id<SMRequestableDelegate>)delegate forRequest:(SMSingleArtistRequest *)request;

@end

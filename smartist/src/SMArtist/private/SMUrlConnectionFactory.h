//
//  SMUrlConnectionFactory.h
//  SMArtist
//
//  Created by Fabian on 05.09.11.
//  Copyright (c) 2011 Spectralmind. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMRootFactory;

@interface SMUrlConnectionFactory : NSObject

@property (nonatomic, weak) SMRootFactory *rootFactory;

- (NSURLConnection *)newUrlConnectionWithRequest:(NSURLRequest *)request withDelegate:(id<NSURLConnectionDelegate, NSURLConnectionDataDelegate>)delegate;

@end

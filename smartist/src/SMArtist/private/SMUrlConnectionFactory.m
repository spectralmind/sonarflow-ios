//
//  SMUrlConnectionFactory.m
//  SMArtist
//
//  Created by Fabian on 05.09.11.
//  Copyright (c) 2011 Spectralmind. All rights reserved.
//

#import "SMUrlConnectionFactory.h"

@implementation SMUrlConnectionFactory
{
    SMRootFactory *__weak rootFactory;
}

@synthesize rootFactory;

- (NSURLConnection *)newUrlConnectionWithRequest:(NSURLRequest *)request withDelegate:(id<NSURLConnectionDelegate, NSURLConnectionDataDelegate>)delegate
{
    return [[NSURLConnection alloc] initWithRequest:request delegate:delegate];
}

@end

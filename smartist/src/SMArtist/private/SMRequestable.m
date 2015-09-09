//
//  SMRequestable.m
//  SMArtist
//
//  Created by Fabian on 06.12.11.
//  Copyright (c) 2011 Spectralmind. All rights reserved.
//

#import "SMRequestable.h"

#import "SMRootFactory.h"

#import "SMArtistSimilarityResult.h"
#import "SMArtistBiosResult.h"
#import "SMArtistImagesResult.h"


@implementation SMRequestable
{
@private
    SMRootFactory *__weak rootFactory;
    id<SMRequestableDelegate> __weak delegate;
}

@synthesize rootFactory;
@synthesize delegate;

- (id)init
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)initWithConfiguration:(SMRootFactory *)theConfigfactory withDelegate:(id<SMRequestableDelegate>)theDelegate
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.rootFactory = theConfigfactory;
        self.delegate = theDelegate;
    }
    
    return self;
}


- (void)startRequest
{
    [self doesNotRecognizeSelector:_cmd];
}

@end

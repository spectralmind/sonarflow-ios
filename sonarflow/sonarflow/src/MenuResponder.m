//
//  MenuResponder.m
//  Sonarflow
//
//  Created by Raphael Charwot on 12.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import "MenuResponder.h"


@implementation MenuResponder

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (BOOL)canBecomeFirstResponder {
	return YES;
}

#pragma mark MenuCommands

- (void)play {
	[self.delegate play];
}

- (void)addToPlaylist {
	[self.delegate addToPlaylist];
}

- (void)addToPreviousPlaylist {
	[self.delegate addToPreviousPlaylist];
}

@end

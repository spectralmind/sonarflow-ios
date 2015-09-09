//
//  MenuResponder.h
//  Sonarflow
//
//  Created by Raphael Charwot on 12.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuCommands

- (void)play;
- (void)addToPlaylist;
- (void)addToPreviousPlaylist;

@end

@interface MenuResponder : UIView
		<MenuCommands> {
	id<MenuCommands> __weak delegate;
}

@property (nonatomic, weak) id<MenuCommands> delegate;

@end



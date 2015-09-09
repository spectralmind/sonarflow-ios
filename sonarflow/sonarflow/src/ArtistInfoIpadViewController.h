//
//  ArtistInfoIpadViewController.h
//  sonarflow
//
//  Created by Fabian on 07.01.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ArtistInfoViewController.h"

@protocol OverlayCloseRequestDelegate;


@interface ArtistInfoIpadViewController : ArtistInfoViewController

@property (nonatomic, weak) id<OverlayCloseRequestDelegate> artistInfoIpadDelegate;

@end


@protocol OverlayCloseRequestDelegate <NSObject>

- (void)dismissOverlay:(UIViewController *)presentedViewController;

@end

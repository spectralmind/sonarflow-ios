//
//  ArtistInfoIpadViewTitleCell.h
//  sonarflow
//
//  Created by Fabian on 13.01.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InfoIpadView.h"

@interface InfoIpadViewTitleView : UIView

@property (nonatomic, weak) id<InfoIpadViewCloseDelegate> infoIpadViewCloseDelegate;

@property (nonatomic, strong) NSString *title;

- (void)addFacebookButton:(UIButton *)fbButton andTwitterButton:(UIButton *)twButton;

@end


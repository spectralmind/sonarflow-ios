//
//  ArtistInfoIphoneView.h
//  sonarflow
//
//  Created by Fabian on 07.01.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InfoIphoneViewPage : UIView

@property (nonatomic, readonly) UIView *containerView;
@property (nonatomic, readonly) UILabel *errorLabel;
@property (nonatomic, readonly) UIActivityIndicatorView *spinner;

@end

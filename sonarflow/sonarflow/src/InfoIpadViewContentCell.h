//
//  ArtistInfoIpadViewCell.h
//  sonarflow
//
//  Created by Fabian on 13.01.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoIpadViewContentCell : UITableViewCell

@property (nonatomic, strong) NSString *title;
@property (nonatomic, readonly) UIView *containerView;
@property (nonatomic, readonly) UILabel *errorLabel;
@property (nonatomic, readonly) UIActivityIndicatorView *spinner;
@property (nonatomic, assign) CGFloat contentHeight;

- (void)redisplay;

@end

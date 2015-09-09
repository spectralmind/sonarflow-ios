//
//  ArtistInfoIpadViewTitleCell.m
//  sonarflow
//
//  Created by Fabian on 13.01.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "InfoIpadViewTitleView.h"
#import <QuartzCore/QuartzCore.h>

#import "UILabelWithMargin.h"

static const CGFloat labelLeftMargin = 34.f;
static const CGFloat labelTopMargin = -3.f; //label gets vertically centered

static const CGFloat closeButtonTopMargin = 14.f;
static const CGFloat closeButtonRightMargin = 0.f;
static const CGFloat closeButtonWidth = 60.f;
static const CGFloat closeButtonHeight = 45.f;

@interface InfoIpadViewTitleView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *closeButton;

@end



@implementation InfoIpadViewTitleView {
@private
	UILabelWithMargin *_titleLabel;
}

@synthesize titleLabel = _titleLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self createElementsWithFrame:frame];
	}
    return self;
}

- (void)awakeFromNib {
	[self createElementsWithFrame:self.frame];
}

- (void)createElementsWithFrame:(CGRect)frame {
	// Initialization code
	self.titleLabel = [[UILabelWithMargin alloc] initWithFrame:frame];
	_titleLabel.inset = UIEdgeInsetsMake(labelTopMargin, labelLeftMargin, 0.f, 0.f);
	self.titleLabel.font = [UIFont systemFontOfSize:42.0];

	self.titleLabel.textColor = [UIColor whiteColor];
	
	self.titleLabel.backgroundColor = [UIColor clearColor];
	self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
	[self addSubview:self.titleLabel];
	
	CGRect closeFrame = CGRectMake(frame.size.width - closeButtonWidth - closeButtonRightMargin, closeButtonTopMargin, closeButtonWidth, closeButtonHeight);
	
	self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.closeButton.frame = closeFrame;
	self.closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	self.closeButton.titleLabel.textColor = [UIColor whiteColor];
	UIImage *closeButtonImage = [UIImage imageNamed:@"info_close_button.png"];
	[self.closeButton setImage:closeButtonImage forState:UIControlStateNormal];
	[self.closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:self.closeButton];
}

- (void)setTitle:(NSString *)title
{
	self.titleLabel.text = title;
}

- (NSString *)title
{
	return self.titleLabel.text;
}

- (void)addFacebookButton:(UIButton *)fbButton andTwitterButton:(UIButton *)twButton {
	
	CGPoint center = self.closeButton.center;
		
	center.x -= twButton.frame.size.width + 15.0;
	
	twButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	twButton.center = center;
	
	center.x -= fbButton.frame.size.width + 30.0;
	
	fbButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	fbButton.center = center;

	[self addSubview:fbButton];
	[self addSubview:twButton];
}

#pragma mark Target Action Methods

- (void)close:(id)sender
{
	[self.infoIpadViewCloseDelegate closeView];
}


@end

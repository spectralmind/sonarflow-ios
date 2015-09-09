//
//  ArtistInfoIpadViewCell.m
//  sonarflow
//
//  Created by Fabian on 13.01.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "InfoIpadViewContentCell.h"

#import "UILabelWithMargin.h"

static const CGFloat labelWidth = 149.f;
static const CGFloat labelHeight = 27.f;
static const CGFloat labelLeftMargin = 35.f;
static const CGFloat labelTopMargin = 0.f; // label gets vertically centered
static const CGFloat labelFontSize = 19.f;

static const CGFloat errorLabelFontSize = 19.f;

static const CGFloat spinnerLeftMargin = labelWidth;
static const CGFloat spinnerTopMargin = 4.f;


@interface InfoIpadViewContentCell ()

@property (nonatomic, readonly) UILabel *titleLabel;

@end


@implementation InfoIpadViewContentCell {
@private
	UILabelWithMargin *_titleLabel;
}

@synthesize titleLabel = _titleLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		CGSize contentSize = CGSizeMake(self.contentView.bounds.size.width, self.contentView.bounds.size.height);
		
		_titleLabel = [[UILabelWithMargin alloc] initWithFrame:CGRectMake(0.f, 0.f, labelWidth, labelHeight)];
		_containerView = [[UIView alloc] initWithFrame:CGRectMake(labelWidth, 0.f, contentSize.width - labelWidth, contentSize.height)];
		_errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth, 0.f, contentSize.width - labelWidth, labelHeight)];
		_spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		
		CGRect spinnerFrame = _spinner.frame;
		spinnerFrame.origin = CGPointMake(spinnerLeftMargin, spinnerTopMargin);
		self.spinner.frame = spinnerFrame;
		
		_titleLabel.inset = UIEdgeInsetsMake(labelTopMargin, labelLeftMargin, 0.f, 0.f);
		self.titleLabel.font = [UIFont boldSystemFontOfSize:labelFontSize];
		self.titleLabel.textColor = [UIColor whiteColor];
		self.titleLabel.backgroundColor = [UIColor clearColor];
		
		self.containerView.backgroundColor = [UIColor clearColor];
		self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		self.errorLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.errorLabel.font = [UIFont systemFontOfSize:errorLabelFontSize];;
		self.errorLabel.textColor = [UIColor whiteColor];
		self.errorLabel.backgroundColor = [UIColor clearColor];
		
		[self.contentView addSubview:self.titleLabel];
		[self.contentView addSubview:self.containerView];
		[self.contentView addSubview:self.errorLabel];
        [self.contentView addSubview:self.spinner];
	}
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    return;
}

- (void)redisplay {
	[self.containerView setNeedsDisplay];
}


- (void)setTitle:(NSString *)title
{
	self.titleLabel.text = title;
}

- (NSString *)title
{
	return self.titleLabel.text;
}

- (void)setContentHeight:(CGFloat)contentHeight
{
	CGRect contentFrame = self.containerView.frame;
	contentFrame.size.height = contentHeight;
	self.containerView.frame = contentFrame;
}

- (CGFloat)contentHeight
{
	return self.contentView.frame.size.height;
}

@end
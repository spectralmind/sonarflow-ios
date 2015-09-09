//
//  ArtistInfoIphoneView.m
//  sonarflow
//
//  Created by Fabian on 07.01.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "InfoIphoneViewPage.h"

static const CGFloat errorLabelFontSize = 16.f;


@implementation InfoIphoneViewPage
{
@private
	CGRect oldBounds;
}

- (id)init {
	return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		oldBounds = frame;
		frame.origin = CGPointZero;
		
		self.backgroundColor = [UIColor clearColor];
		_containerView = [[UIView alloc] initWithFrame:frame];
		_errorLabel = [[UILabel alloc] initWithFrame:frame];
		_spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		self.spinner.center = self.containerView.center;
		self.spinner.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		
		self.containerView.backgroundColor = [UIColor clearColor];
		self.containerView.opaque = NO;
		self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		self.errorLabel.font = [UIFont systemFontOfSize:errorLabelFontSize];
		self.errorLabel.textColor = [UIColor whiteColor];
		self.errorLabel.backgroundColor = [UIColor clearColor];
		self.errorLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.errorLabel.numberOfLines = 0;

		[self.errorLabel setTextAlignment:UITextAlignmentCenter];
		
		[self addSubview:self.containerView];
		[self addSubview:self.errorLabel];
		[self addSubview:self.spinner];
    }
    return self;
}

@end

//
//  ArtistInfoIphoneViewController.m
//  sonarflow
//
//  Created by Arvid Staub on 07.06.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "ArtistInfoIphoneViewController.h"
#import "UIView+ClearMargins.h"
#import "ArtistSharingDelegate.h"

@implementation ArtistInfoIphoneViewController 

#define kHeaderHeight 46
#define kShareButtonInsetRight	7
#define	kShareButtonInsetTop	17
#define kShareButtonGap			20

- (void)viewDidAppear:(BOOL)animated {
	BOOL update = self.updateWhenViewAppearsNextTime;
	[super viewDidAppear:animated];

	if (update) {
		[self.facebookButton removeFromSuperview];
		[self.twitterButton removeFromSuperview];
		
		[self.view clearTop:kHeaderHeight];

		CGRect buttonFrame = CGRectMake(self.view.frame.size.width - self.twitterButton.frame.size.width - kShareButtonInsetRight, kShareButtonInsetTop, self.twitterButton.frame.size.width, self.twitterButton.frame.size.height);
		
		self.twitterButton.frame = buttonFrame;
		self.twitterButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
		
		buttonFrame.origin.x -= kShareButtonGap + self.facebookButton.frame.size.width;
		buttonFrame.size = self.facebookButton.frame.size;
		
		self.facebookButton.frame = buttonFrame;
		self.facebookButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
		
			
		[self.view addSubview:self.facebookButton];
		[self.view addSubview:self.twitterButton];
	}
}

@end

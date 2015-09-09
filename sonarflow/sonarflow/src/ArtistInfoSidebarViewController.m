//
//  ArtistInfoSidebarViewController.m
//  sonarflow
//
//  Created by Arvid Staub on 14.05.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "ArtistInfoSidebarViewController.h"
#import "NSString+CGLogging.h"
#import "ArtistSharingDelegate.h"
#import "UIView+ClearMargins.h"

@class ScrollingVideoView;

@implementation ArtistInfoSidebarViewController {
	UILabel *headerView;
	UIButton *shareButton;
}

#define kHeaderHeight 46
#define kHeaderLeftMargin 0


- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor clearColor];
	
	headerView = [[UILabel alloc] init];
	shareButton = [UIButton buttonWithType:UIButtonTypeCustom];

	[super viewDidLoad];
}

#define kShareButtonInsetRight	12.0
#define kShareButtonInsetTop	 7.0

- (void)viewDidAppear:(BOOL)animated {
	BOOL update = self.updateWhenViewAppearsNextTime;
	[super viewDidAppear:animated];

	if (update) {
		[self.view clearTop:kHeaderHeight];
		[self layoutAndAddArtistNameHeader];
		[self layoutAndAddShareButton];

		// patch biography view: get rid of the intrinsic content inset to align it with the headerView tabel
		UIWebView *bioView = [super biographyView];
		bioView.scrollView.contentInset = UIEdgeInsetsMake(0, -7, 0, 0);
	}
}


- (void)layoutAndAddArtistNameHeader {
	CGRect headerFrame = CGRectMake(kHeaderLeftMargin, 0, self.view.frame.size.width - kHeaderLeftMargin, kHeaderHeight);
	headerView.frame = headerFrame;
	headerView.autoresizingMask = UIViewAutoresizingNone;
	headerView.textAlignment = UITextAlignmentLeft;
	headerView.textColor = [UIColor whiteColor];
	headerView.backgroundColor = [UIColor clearColor];
	headerView.font = [UIFont boldSystemFontOfSize:19.0];
	[self.view addSubview:headerView];
}

- (void)layoutAndAddShareButton {
	UIImage *shareIcon = [UIImage imageNamed:@"icon_shareCombined"];
	[shareButton setBackgroundImage:shareIcon forState:UIControlStateNormal];
	shareButton.frame = CGRectMake(self.view.frame.size.width - shareIcon.size.width - kShareButtonInsetRight,kShareButtonInsetTop, shareIcon.size.width, shareIcon.size.height);
	[shareButton addTarget:self action:@selector(handleShareButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:shareButton];
}

- (void)handleShareButtonTapped:(UIButton *)sender {
	NSLog(@"tapped share button.");
	[self.sharingDelegate shareArtist:self.artistName fromButton:sender];
}

- (void)viewDidDisappear:(BOOL)animated {
	[headerView removeFromSuperview];
	[super viewDidDisappear:animated];
}

- (CGSize)scrollingVideoViewSizeOfVideos:(ScrollingVideoView *)scrollingNetworkImageView {
	return CGSizeMake(148, 111);
}


- (void)setArtistName:(NSString *)artistName {
	headerView.text = artistName;
	[super setArtistName:artistName];
}
@end

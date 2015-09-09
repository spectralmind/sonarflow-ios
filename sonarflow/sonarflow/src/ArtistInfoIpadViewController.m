//
//  ArtistInfoIpadViewController.m
//  sonarflow
//
//  Created by Fabian on 07.01.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "ArtistInfoIpadViewController.h"
#import "ArtistInfoViewController+Private.h"

#import "InfoIpadView.h"
#import "UILabelWithMargin.h"
#import "CTView.h"
#import "NSAttributedString+Attributes.h"
#import "SMArtist.h"
#import "ScrollingVideoView.h"
#import "NSString+HTML.h"

static const NSUInteger sectionCount = 3;

static const NSUInteger sectionNumberVideos    = 0;
static const NSUInteger sectionNumberBiography = 1;
static const NSUInteger sectionNumberCredits   = 2;
static const NSUInteger sectionNumberAlbums    = 4;

static NSString * const sectionTitlePictures  = @"Pictures";
static NSString * const sectionTitleVideos    = @"Videos";
static NSString * const sectionTitleBiography = @"Biography";
static NSString * const sectionTitleAlbums    = @"Albums";
static NSString * const sectionTitleCredits   = @"";

static const CGFloat sectionContentHeightPictures  = 140.f;
static const CGFloat sectionContentHeightVideos    = 140.f;
static const CGFloat sectionContentHeightBiography = 365.f;
static const CGFloat sectionContentHeightAlbums    = 140.f;
static const CGFloat sectionContentHeightCredits   = 88.f;

static const CGFloat editBioButtonHeight           = 42;
static const CGFloat editBioButtonWidth			   = 162;

static const CGFloat sectionSpacing = 40.f;

static const CGFloat biographyTextInsetTop = 4.f;
static const CGFloat biographyTextColumnWidth = 340.f;
static const CGFloat biographyTextColumnSpacing = 20.f;
static const CGFloat biographyTextFontSize = 18.f;

static const CGFloat picturesImageWidth  = 167.f;
static const CGFloat picturesImageSpacing = 10.f;

static const NSUInteger videosMaxCount = 10;
static const CGFloat videosSpacing = 10.f;
static const CGFloat videosWidth  = 167.f;
static const CGFloat videosHeight  = 132.f;

static const CGFloat creditTextFontSize = 18.f;
static const CGFloat creditLastfmTextLeftMargin = 0.f;
static const CGFloat creditLastfmTextTopMargin = 0.f;
static const CGFloat creditLastfmTextWidth = 100.f;
static const CGFloat creditLastfmTextHeight = 26.f;
static NSString * const creditLastfmText = @"powered by";
static NSString * const creditLastfmUrl = @"http://www.lastfm.com";
static NSString * const creditLastfmImageName = @"lastfm_logo_white.png";
static const CGFloat creditLastfmImageLeftMargin = 0.f;
static const CGFloat creditLastfmImageTopMargin = 38.f;


@interface ArtistInfoIpadViewController () <InfoIpadViewCloseDelegate, InfoIpadViewDelegate, UIScrollViewDelegate, ScrollingVideoViewDelegate>

@property (nonatomic, strong) ScrollingVideoView *videosView;
@property (nonatomic, strong) CTView *biographyView;
@property (nonatomic, strong) UIView *bioContainerView;
@property (nonatomic, strong) UIButton *bioLinkButton;
@property (nonatomic, strong) UIView *creditsView;

@end


@implementation ArtistInfoIpadViewController {
	@private
	BOOL allowReload;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
	[self removeViews];
	self.updateWhenViewAppearsNextTime = YES;
}

#pragma mark - View lifecycle

- (void)loadView
{
	InfoIpadView *v = [[InfoIpadView alloc] initWithFrame:CGRectZero];
	v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	v.infoIpadViewDelegate = self;
	v.userInteractionEnabled = YES;
	
	[v addFacebookButton:self.facebookButton andTwitterButton:self.twitterButton];
	
	self.view = v;
}

- (void)reloadView
{
	if (allowReload) {
		[(InfoIpadView *)self.view reloadData];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	BOOL update = self.updateWhenViewAppearsNextTime;
	allowReload = NO;
	[super viewWillAppear:animated];
	allowReload = YES;

	if (update) {
		[(InfoIpadView *)self.view setContentOffset:CGPointZero animated:NO];
		[self reloadView];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	BOOL update = self.updateWhenViewAppearsNextTime;
	[super viewDidAppear:animated];

	if (update) {
		[(InfoIpadView *)self.view flashScrollIndicators];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{	
	allowReload = NO;
	[self postStopYoutubePlaybackNotification];
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
	// deprecated in iOS 6
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// deprecated in iOS 6
	return YES;
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

#pragma mark - Hooks on super's Properties

- (void)setArtistName:(NSString *)artistName
{
	[super setArtistName:artistName];
	[self reloadView];
}

- (void)setArtistVideos:(NSArray *)artistVideos
{
	[super setArtistVideos:artistVideos];
	[self.videosView reloadData]; // don't create videosView until needed
	[self reloadView];
}

- (void)setBiographyText:(NSString *)biographyText
{
	[super setBiographyText:biographyText];
	[self updateBiographyViewText];
	[self reloadView];
}

- (void)setNoBio:(NSString *)noBio
{
	[super setNoBio:noBio];
	[self reloadView];
}

- (void)setNoImages:(NSString *)noImages
{
	[super setNoImages:noImages];
	[self reloadView];
}

- (void)setNoVideos:(NSString *)noVideos
{
	[super setNoVideos:noVideos];
	[self reloadView];
}

#pragma mark - Properties for Views

- (void)removeViews
{
	if (self.videosView.window == nil) {
		[self.videosView removeFromSuperview], self.videosView = nil;
	}
	
	if (self.bioContainerView.window == nil) {
		[self.bioContainerView removeFromSuperview];
		self.bioContainerView = nil;
	}
	
	if (self.bioLinkButton.window == nil) {
		[self.bioLinkButton removeFromSuperview];
		self.bioLinkButton = nil;
	}
	
	if (self.biographyView.window == nil) {
		[self.biographyView removeFromSuperview];
		self.biographyView = nil;
	}
	
	if (self.creditsView.window == nil) {
		[self.creditsView removeFromSuperview], self.creditsView = nil;
	}
}

- (ScrollingVideoView *)videosView
{
	if(_videosView == nil) {
		_videosView = [[ScrollingVideoView alloc] initWithFrame:CGRectZero horizontallyScrollingWithVideoSpacing:videosSpacing];
		_videosView.backgroundColor = [UIColor clearColor];
		_videosView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_videosView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
		_videosView.scrollingVideoViewDelegate = self;
		
		[_videosView reloadData];
	}
	return _videosView;
}


- (CTView *)biographyView {
	
	if(_biographyView != nil) {
		return _biographyView;
	}
	
	_biographyView = [[CTView alloc] initWithFrame:CGRectMake(0, 0, editBioButtonWidth, 0)];

	_biographyView.inset = UIEdgeInsetsMake(biographyTextInsetTop, 0.f, 0.f, 0.f);
	_biographyView.frameWidth = biographyTextColumnWidth;
	_biographyView.frameSpacing = biographyTextColumnSpacing;
	_biographyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_biographyView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
		
	[self updateBiographyViewText];
	
	return _biographyView;
}

- (UIView *)bioContainerView {
	if(_bioContainerView != nil) {
		return _bioContainerView;
	}
	
	_bioContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, editBioButtonWidth, editBioButtonHeight+10)];

	_bioContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
	[_bioContainerView addSubview:self.biographyView];
	[_bioContainerView addSubview:self.bioLinkButton];
	[_bioContainerView setUserInteractionEnabled:YES];
	
	return _bioContainerView;
}

- (UIButton *)bioLinkButton {
	
	if(_bioLinkButton != nil) {
		return _bioLinkButton;
	}
		
	_bioLinkButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, editBioButtonWidth, editBioButtonHeight)];
	_bioLinkButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	
	[_bioLinkButton setBackgroundImage:[UIImage imageNamed:@"info_button_regular.png"] forState:UIControlStateNormal];
	[_bioLinkButton setTitle:@"read on last.fm" forState:UIControlStateNormal];
	[_bioLinkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	[_bioLinkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
	[_bioLinkButton addTarget:self action:@selector(lastfmBioEditTapped:) forControlEvents:UIControlEventTouchUpInside];
	[_bioLinkButton setUserInteractionEnabled:YES];
	
	_bioLinkButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];

	return _bioLinkButton;
}

- (void)updateBiographyViewText {
	NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:[self.biographyText stringByConvertingHTMLToPlainTextLeavingWhitespace]];
	[attrStr setFont:[UIFont systemFontOfSize:biographyTextFontSize]];
	[attrStr setTextColor:[UIColor whiteColor]];
	[attrStr setTextAlignment:kCTJustifiedTextAlignment lineBreakMode:kCTLineBreakByWordWrapping];
	
	[self.biographyView setAttString:attrStr withImages:nil]; // don't create biographyView until needed
}

- (UIView *)creditsView
{
	if(_creditsView == nil) {
		_creditsView = [[UIView alloc] initWithFrame:CGRectZero];
		_creditsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		UILabel *lastfmLabel = [[UILabel alloc] initWithFrame:CGRectMake(creditLastfmTextLeftMargin, creditLastfmTextTopMargin, creditLastfmTextWidth, creditLastfmTextHeight)];
		lastfmLabel.text = creditLastfmText;
		lastfmLabel.font = [UIFont systemFontOfSize:creditTextFontSize];
		lastfmLabel.textColor = [UIColor whiteColor];
		lastfmLabel.backgroundColor = [UIColor clearColor];

		UIImage *lastfmImage = [UIImage imageNamed:creditLastfmImageName];
		
		UIButton *lastfmImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
		lastfmImageButton.frame = CGRectMake(creditLastfmImageLeftMargin, creditLastfmImageTopMargin, lastfmImage.size.width, lastfmImage.size.height);
		[lastfmImageButton setImage:lastfmImage forState:UIControlStateNormal];
		[lastfmImageButton addTarget:self action:@selector(lastfmImageTapped:) forControlEvents:UIControlEventTouchUpInside];
		
		[_creditsView addSubview:lastfmLabel];
		[_creditsView addSubview:lastfmImageButton];
	}
	return _creditsView;
}

- (void)lastfmBioEditTapped:(UIButton *)sender {
	NSLog(@"tapped edit: %@\n", self.biographyURL);
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.biographyURL]];
}

- (void)lastfmImageTapped:(UIButton *)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:creditLastfmUrl]];
}



#pragma mark - Sections

- (BOOL)isVideosSection:(NSUInteger)index {
	return index == sectionNumberVideos;
}

- (BOOL)isBiographySection:(NSUInteger)index {
	return index == sectionNumberBiography;
}

- (BOOL)isAlbumsSection:(NSUInteger)index {
	return index == sectionNumberAlbums;
}

- (BOOL)isCreditsSection:(NSUInteger)index {
	return index == sectionNumberCredits;
}


#pragma mark - InfoIpadViewCloseDelegate Delegate

- (void)closeView
{
	[self.artistInfoIpadDelegate dismissOverlay:self];
}


#pragma mark - InfoIpadViewDelegate Delegate

- (NSString *)infoIpadViewStringForTitle:(InfoIpadView *)infoIpadView {
	return self.artistName;
}

- (NSUInteger)infoIpadViewNumberOfRows:(InfoIpadView *)infoIpadView {
	return sectionCount;
}

- (CGFloat)infoIpadViewSpaceBetweenRows:(InfoIpadView *)infoIpadView {
	return sectionSpacing;
}

- (CGFloat)infoIpadView:(InfoIpadView *)infoIpadView heightForContentOfRowWithIndex:(NSUInteger)index {
	CGFloat contentHeight = 0.f;
	
	if ([self isVideosSection:index]) {
		contentHeight = sectionContentHeightVideos;
	} else if ([self isBiographySection:index]) {
		contentHeight = sectionContentHeightBiography;
	} else if ([self isAlbumsSection:index]) {
		contentHeight = sectionContentHeightAlbums;
	} else if ([self isCreditsSection:index]) {
		contentHeight = sectionContentHeightCredits;
	}
	
	return contentHeight;
}

- (NSString *)infoIpadView:(InfoIpadView *)infoIpadView titleForRowWithIndex:(NSUInteger)index {
	if ([self isVideosSection:index]) {
		return sectionTitleVideos;
	} else if ([self isBiographySection:index]) {
		return sectionTitleBiography;
	} else if ([self isAlbumsSection:index]) {
		return sectionTitleAlbums;
	} else if ([self isCreditsSection:index]) {
		return sectionTitleCredits;
	} 
	
	return nil;
}

- (UIView *)infoIpadView:(InfoIpadView *)infoIpadView contentViewForRowWithIndex:(NSUInteger)index {
	if ([self isVideosSection:index]) {
		return self.videosView;
	} else if ([self isBiographySection:index]) {
		return self.bioContainerView;
	} else if ([self isAlbumsSection:index]) {
		return nil;
	} else if ([self isCreditsSection:index]) {
		return self.creditsView;
	}
	
	return nil;
}


- (InfoIpadViewSectionState)infoIpadView:(InfoIpadView *)infoIpadView stateOfRowWithIndex:(NSUInteger)index
{
	if ([self isVideosSection:index]) {
		if (self.artistVideos) {
			return InfoIpadViewSectionStateLoaded;
		} else if (self.noVideos) {
			return InfoIpadViewSectionStateFailed;
		} else {
			return InfoIpadViewSectionStateLoading;
		}
	} else if ([self isBiographySection:index]) {
		if (self.biographyText) {
			return InfoIpadViewSectionStateLoaded;
		} else if (self.noBio) {
			return InfoIpadViewSectionStateFailed;
		} else {
			return InfoIpadViewSectionStateLoading;
		}
	} else if ([self isAlbumsSection:index]) {
		return InfoIpadViewSectionStateLoaded;
	} else if ([self isCreditsSection:index]) {
		return InfoIpadViewSectionStateLoaded;
	}
	return InfoIpadViewSectionStateLoaded;
}

- (NSString *)infoIpadView:(InfoIpadView *)infoIpadView failedMessageOfRowWithIndex:(NSUInteger)index
{
	if ([self isVideosSection:index]) {
		return self.noVideos;
	} else if ([self isBiographySection:index]) {
		return self.noBio;
	} else if ([self isAlbumsSection:index]) {
		return nil;
	} else if ([self isCreditsSection:index]) {
		return nil;
	} 
	
	return nil;
}


#pragma mark - ScrollingVideoViewDelegate

- (NSUInteger)scrollingVideoViewNumberOfVideos:(ScrollingVideoView *)scrollingNetworkImageView
{
	return fmin([self.artistVideos count], videosMaxCount);
}

- (SMArtistVideo *)scrollingVideoView:(ScrollingVideoView *)scrollingNetworkImageView videoWithIndex:(NSUInteger)index
{
	if ([self.artistVideos count] <= index) {
		return nil;
	}
	
	return [self.artistVideos objectAtIndex:index];
}

- (CGSize)scrollingVideoViewSizeOfVideos:(ScrollingVideoView *)scrollingNetworkImageView
{
	return CGSizeMake(videosWidth, videosHeight);
}

- (NSString *)artistNameForScrollingVideoView:(ScrollingVideoView *)scrollingVideoView {
	return self.artistName;
}

@end

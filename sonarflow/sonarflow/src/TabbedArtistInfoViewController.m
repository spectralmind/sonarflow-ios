//
//  ArtistInfoIphoneViewController.m
//  sonarflow
//
//  Created by Fabian on 07.01.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "TabbedArtistInfoViewController.h"
#import "ArtistInfoViewController+Private.h"

#import "InfoIphoneView.h"
#import "SMArtist.h"
#import "ScrollingVideoView.h"
#import "Notifications.h"

static const NSUInteger pageCount = 2; //4

static const NSUInteger pageNumberVideos    = 1;
static const NSUInteger pageNumberBiography = 0;
static const NSUInteger pageNumberAlbums    = 3;

static NSString * const pageNamePictures  = @"Pictures";
static NSString * const pageNameVideos    = @"Videos";
static NSString * const pageNameBiography = @"Biography";
static NSString * const pageNameAlbums    = @"Albums";

static NSString * const pageTabImageNamePictures  = @"";
static NSString * const pageTabImageNameVideos    = @"artistinfo_video_active.png";
static NSString * const pageTabImageNameBiography = @"artistinfo_bio_active.png";
static NSString * const pageTabImageNameAlbums    = @"";

static const CGFloat biographyTextFontSize = 15.f;

static const CGFloat picturesImageWidth  = 79.f;
static const CGFloat picturesImageHeight = 79.f;
static const CGFloat picturesImageSpacing = 1.f;

static const NSUInteger videosMaxCount = 15;
static const CGFloat videosSpacing = 1.f;
static const CGFloat videosWidth  = 106.f;
static const CGFloat videosHeight  = 80.f;



@interface TabbedArtistInfoViewController () <InfoIphoneViewDelegate, ScrollingVideoViewDelegate, UIScrollViewDelegate, UIWebViewDelegate>

@property (weak, nonatomic, readonly) ScrollingVideoView *videosView;
@property (weak, nonatomic, readonly) UIWebView *biographyView;

@end


@implementation TabbedArtistInfoViewController
{
@private
	ScrollingVideoView *videosView;
	UIWebView *biographyView;
	BOOL allowReload;
	NSMutableDictionary *tabBarImages;
}

- (void)dealloc {
	// remove if UIWebView has weak delegate property
	biographyView.delegate = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		tabBarImages = [NSMutableDictionary dictionaryWithCapacity:pageCount];
    }
    return self;
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
	InfoIphoneView *v = [[InfoIphoneView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
	v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	v.infoIphoneViewDelegate = self;
	v.backgroundColor = [UIColor blackColor];
	[v populateTabBar];
	
	self.view = v;
}

- (void)reloadView
{
	if (allowReload) {
		[(InfoIphoneView *)self.view reloadData];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	BOOL update = self.updateWhenViewAppearsNextTime;
	allowReload = NO;
	[super viewWillAppear:animated];
	allowReload = YES;
	
	if (update) {
		[(InfoIphoneView *)self.view showPageAtIndex:0];
		[self reloadView];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
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

- (void)setArtistVideos:(NSArray *)artistVideos
{
	[super setArtistVideos:artistVideos];
	[videosView reloadData]; // don't create videosView until needed
	[self reloadView];
    [videosView setContentOffset:CGPointZero animated:YES];
}

- (void)setBiographyText:(NSString *)biographyText {
    if(biographyText == nil) {
        return;
    }
    
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

- (void)removeViews {
	if (videosView.window == nil) {
		[videosView removeFromSuperview];
		videosView = nil;
	}
	
	if (biographyView.window == nil) {
		biographyView.delegate = nil;
		[biographyView removeFromSuperview];
		biographyView = nil;
	}
}

- (UIView *)videosView
{
	if(videosView == nil) {
		videosView = [[ScrollingVideoView alloc] initWithFrame:CGRectZero verticallyScrollingWithVideoSpacing:videosSpacing];
		videosView.opaque = NO;
		videosView.backgroundColor = [UIColor clearColor];
		videosView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		videosView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
		videosView.scrollingVideoViewDelegate = self;
		
		[videosView reloadData];
	}
	return videosView;
}


- (UIWebView *) biographyView {
	if(biographyView == nil) {
        biographyView = [[UIWebView alloc] initWithFrame:CGRectZero];
        biographyView.backgroundColor = [UIColor clearColor];
        biographyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        biographyView.opaque = NO;
        biographyView.backgroundColor = [UIColor clearColor];
        biographyView.delegate = self;
	
		[self updateBiographyViewText];
	}
    
	return biographyView;
}

- (void)updateBiographyViewText {
	NSString *bio = [self.biographyText stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
	NSString *htmlString = [NSString stringWithFormat:@"<style>body {color: white; font: 11pt Helvetica;}\n a:link {color: white}</style>\n%@<br><br><br>Biography from <a href='%@'>last.fm</a>", bio, self.biographyURL];
    [biographyView loadHTMLString:htmlString baseURL:nil];
}


#pragma mark - Pages

- (BOOL)isVideosPage:(NSInteger)page
{
	return page == pageNumberVideos;
}
- (BOOL)isBiographyPage:(NSInteger)page
{
	return page == pageNumberBiography;
}
- (BOOL)isAlbumsPage:(NSInteger)page
{
	return page == pageNumberAlbums;
}


#pragma mark Tab Bar Images

- (UIImage *)tabBarImageWithImageName:(NSString *)imageName withKey:(NSString *)key
{
	UIImage *tabBarImage = [tabBarImages objectForKey:key];
	if (tabBarImage == nil) {
		tabBarImage = [UIImage imageNamed:imageName];
		if (tabBarImage != nil) {
			[tabBarImages setObject:tabBarImage forKey:key];
		}
	}
	return tabBarImage;
}

- (UIImage *)tabBarImagePictures
{
	return [self tabBarImageWithImageName:pageTabImageNamePictures withKey:@"pictures"];
}

- (UIImage *)tabBarImageVideos
{
	return [self tabBarImageWithImageName:pageTabImageNameVideos withKey:@"videos"];
}

- (UIImage *)tabBarImageBiography
{
	return [self tabBarImageWithImageName:pageTabImageNameBiography withKey:@"biography"];
}

- (UIImage *)tabBarImageAlbums
{
	return [self tabBarImageWithImageName:pageTabImageNameAlbums withKey:@"albums"];
}


#pragma mark - InfoIphoneViewDelegate

- (NSUInteger)infoIphoneViewNumberOfPages:(InfoIphoneView *)infoIphoneView
{
	return pageCount;
}

- (NSString *)infoIphoneView:(InfoIphoneView *)infoIphoneView tabTitleForPageWithIndex:(NSUInteger)index
{
	return nil;
}

- (UIImage *)infoIphoneView:(InfoIphoneView *)infoIphoneView tabImageForPageWithIndex:(NSUInteger)index
{
	if ([self isVideosPage:index]) {
		return [self tabBarImageVideos];
	} else if ([self isBiographyPage:index]) {
		return [self tabBarImageBiography];
	} else if ([self isAlbumsPage:index]) {
		return [self tabBarImageAlbums];
	} else {
		return nil;
	}
}

- (UIView *)infoIphoneView:(InfoIphoneView *)infoIphoneView contentViewForPageWithIndex:(NSUInteger)index
{
	if ([self isVideosPage:index]) {
		return self.videosView;
	} else if ([self isBiographyPage:index]) {
		return self.biographyView;
	} else if ([self isAlbumsPage:index]) {
		return nil;
	} else {
		return nil;
	}
}


- (InfoIphoneViewSectionState)infoIphoneView:(InfoIphoneView *)infoIphoneView stateOfPageWithIndex:(NSUInteger)index
{
	if ([self isVideosPage:index]) {
		if (self.artistVideos) {
			return InfoIphoneViewSectionStateLoaded;
		} else if (self.noVideos) {
			return InfoIphoneViewSectionStateFailed;
		} else {
			return InfoIphoneViewSectionStateLoading;
		}
	} else if ([self isBiographyPage:index]) {
		if (self.biographyText) {
			return InfoIphoneViewSectionStateLoaded;
		} else if (self.noBio) {
			return InfoIphoneViewSectionStateFailed;
		} else {
			return InfoIphoneViewSectionStateLoading;
		}
	} else if ([self isAlbumsPage:index]) {
		return InfoIphoneViewSectionStateLoaded;
	}
	return InfoIphoneViewSectionStateLoaded;
}

- (NSString *)infoIphoneView:(InfoIphoneView *)infoIphoneView failedMessageOfPageWithIndex:(NSUInteger)index
{
	if ([self isVideosPage:index]) {
		return self.noVideos;
	} else if ([self isBiographyPage:index]) {
		return self.noBio;
	} else if ([self isAlbumsPage:index]) {
		return nil;
	}
	return nil;
}

- (void)infoIphoneView:(InfoIphoneView *)infoIphoneView didShowPageWithIndex:(NSUInteger)pageindex {
	[self postStopYoutubePlaybackNotification];
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

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    if(navigationType == UIWebViewNavigationTypeOther) {
        return YES;
    }
    
    if(navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
    }
    
    return NO;
}
@end

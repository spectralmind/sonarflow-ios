//
//  MainViewController.h
//  Sonarflow
//
//  Created by Raphael Charwot on 06.02.11.
//  Copyright 2010 Charwot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MessageUI/MessageUI.h>

#import "PlaybackDelegate.h"
#import "PlaylistEditor.h"
#import "PlaylistsViewController.h"
#import "BubbleViewController.h"
#import "ArtistSharingDelegate.h"

@protocol SFMediaLibrary;
@protocol SFMediaPlayer;
@class AppFactory;
@class PlaylistsViewController;
@class GANHelper;
@class MediaCollectionViewController;
@class TipView;
@class TrackTitleView;
@class SFBubbleHierarchyView;
@class Scrobbler;
@class HintViewController;

@interface MainViewController : UIViewController
		<BubbleViewControllerDelegate, PlaybackDelegate,
		PlaylistEditorDelegate, PlaylistsViewControllerDelegate, MFMailComposeViewControllerDelegate, ArtistSharingDelegate>

@property (nonatomic, weak) IBOutlet UISlider *timeline;
@property (nonatomic, weak) IBOutlet UILabel *currentPlayTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *totalPlayTimeLabel;

@property (nonatomic, weak) IBOutlet SFBubbleHierarchyView *bubbleHierarchyView;
@property (nonatomic, weak) IBOutlet UIView *screenshotHelperView;

@property (nonatomic, weak) IBOutlet TipView *tipView;
@property (nonatomic, weak) IBOutlet UIImageView *headerBackgroundView;
@property (nonatomic, weak) IBOutlet TrackTitleView *trackTitleView;
@property (nonatomic, weak) IBOutlet UIButton *shuffleButton;
@property (nonatomic, weak) IBOutlet UIButton *shuffleEnabledButton;
@property (nonatomic, weak) IBOutlet UIButton *infoButton;
@property (nonatomic, weak) IBOutlet UIButton *toggleDiscoveryButton;
@property (nonatomic, weak) IBOutlet UIView *overlayContainerView;

@property (nonatomic, strong) NSObject<SFMediaLibrary> *library;
@property (nonatomic, readonly, weak) id<SFMediaPlayer> player;
@property (nonatomic, strong) GANHelper *ganHelper;
@property (nonatomic, strong) NSObject<PlaylistEditor> *playlistEditor;
@property (nonatomic, strong) AppFactory *factory;
@property (nonatomic, strong) Scrobbler *scrobbler;

@property (nonatomic, strong, readonly) PlaylistsViewController *playlistsViewController;

- (IBAction)homeButtonPressed;

- (IBAction)playPauseButtonPressed;
- (IBAction)nextSong;
- (IBAction)previousSong;
- (IBAction)beganSettingTimelinePosition;
- (IBAction)setTimelinePosition;
- (IBAction)finishedSettingTimelinePosition;

- (IBAction)playlistsButtonPressed;
- (IBAction)infoButtonPressed;
- (IBAction)shuffleButtonPressed;

- (IBAction)visitSonarflow;
- (IBAction)visitSpectralmind;
- (IBAction)giveFeedback;
- (IBAction)rateApp;
- (IBAction)tappedToggleDiscoveryButton;
- (IBAction)visitLastfm;
- (IBAction)showLastfmSettings;

- (IBAction)crossPromotedProductTapped;

#ifdef SF_SPOTIFY
- (IBAction)spotifyLogout;
- (IBAction)showSpotifyLicense;
#endif

- (MPVolumeView *)newVolumeViewInFrame:(CGRect)frame withSlider:(BOOL)showSlider;

- (void (^)(BOOL shared))facebookSharingDoneBlock;
- (void (^)(BOOL shared))twitterSharingDoneBlock;

//"Virtual" methods
- (void)addHeaderInsetBackground;
- (void)addHeaderBackground;
- (void)showTimeline:(BOOL)show animated:(BOOL)animated;
- (void)showPlaylists;
- (void)dismissPlaylists;
- (BOOL)helpViewIsVisible;
- (void)showHelpView;
- (void)hideHelpView;
- (void)adjustUIBeforeOrientation:(UIInterfaceOrientation)orientation;
- (void)adjustUIAfterOrientation:(UIInterfaceOrientation)orientation;
- (void)setPlayPauseButtonToPlay:(BOOL)play;
- (void)showPreview:(UIViewController *)viewController inRect:(CGRect)rect;
- (void)tappedEmptyLocation:(CGPoint)location;

- (void)showArtistInfoViewForArtist:(id<SFMediaItem>)artist;
- (void)showPartners;
- (void)toggleDiscoveryMode;
- (CGPoint)getCrosshairOffset;
- (void)updateArtistInFocus:(NSString *)artistName;

- (UIImage *)takeScreenshot;

@end

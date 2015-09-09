#import <Foundation/Foundation.h>

@protocol ArtistSharingDelegate;
@protocol OverlayCloseRequestDelegate;
@protocol PlaybackDelegate;
@protocol Player;
@protocol PlaylistEditor;
@protocol PlaylistEditorDelegate;
@protocol SFMediaItem;
@protocol SFMediaLibrary;
@protocol SFPlaylist;
@protocol SMArtistDelegate;

@class ArtistInfoViewController;
@class BubbleFactory;
@class CollectionMenuController;
@class Configuration;
@class DraggableSidebarViewController;
@class ImageFactory;
@class ImageSubmitter;
@class MediaViewControllerFactory;
@class NSManagedObjectContext;
@class PlaylistPicker;
@class PlaylistsTableViewController;
@class ScreenshotFactory;
@class Scrobbler;
@class SFAppIdentity;
@class SFBubbleHierarchyView;
@class SFIPadHelpViewController;
@class SFSmartistFactory;
@class SFZoomHintView;
@class SMArtist;

@interface AppFactory : NSObject

@property (nonatomic, weak) id<PlaylistEditorDelegate> playlistEditorDelegate;

@property (nonatomic, strong) UIView *menuControllerRootView;

@property (nonatomic, strong, readonly) ImageSubmitter *imageSubmitter;
@property (nonatomic, strong, readonly) MediaViewControllerFactory *mediaViewControllerFactory;

@property (nonatomic, strong, readonly) SFSmartistFactory *smartistFactory;

- (id)initWithLibrary:(id<SFMediaLibrary>)theLibrary
		configuration:(Configuration *)theConfiguration
	 playbackDelegate:(id<PlaybackDelegate>)thePlaybackDelegate imageFactory:(ImageFactory *)theImageFactory
	rootViewController:(UIViewController *)theRootViewController;

- (UITableViewCell *)editModeHeaderCell;

- (NSObject<PlaylistEditor> *)playlistEditor;

- (CollectionMenuController *)newMenuController;
- (void)configureSFBubbleHierarchyView:(SFBubbleHierarchyView *)bubbleHierarchyView;

- (ScreenshotFactory *)screenshotFactory;
- (UIViewController *)facebookSubmitControllerForImage:(UIImage *)image withArtistName:(NSString *)artistName done:(void (^)(BOOL shared))doneBlock;
- (UIViewController *)twitterSubmitControllerForImage:(UIImage *)image withArtistName:(NSString *)artistName done:(void (^)(BOOL shared))doneBlock;

- (PlaylistPicker *)playlistPicker;
- (BubbleFactory *)bubbleFactory;

- (ArtistInfoViewController *)artistInfoViewControllerForArtistName:(NSString *)artistName;

- (SFIPadHelpViewController *)helpViewController;
- (Scrobbler *)newScrobbler;

- (NSString *)versionString;
- (NSString *)appName;

- (CGFloat)backgroundImageAlpha;

- (NSString *)devConfiguration;

- (DraggableSidebarViewController *)sidebarControllerWithSharingDelegate:(id<ArtistSharingDelegate>)delegate;
- (ArtistInfoViewController *)sidebarArtistInfoSmall;
- (ArtistInfoViewController *)sidebarArtistInfoFullscreenWithIpadDelegate:(id<OverlayCloseRequestDelegate>)delegate;

- (SFAppIdentity *)appIdentity;

- (SFZoomHintView *)newZoomHintView;

@end
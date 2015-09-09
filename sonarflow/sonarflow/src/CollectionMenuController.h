#import <Foundation/Foundation.h>

#import "MenuResponder.h"

@protocol MenuTargetDelegate;
@protocol CollectionMenuControllerDelegate;
@protocol SFMediaItem;
@class SFMenuTarget;

@interface CollectionMenuController : NSObject

@property (nonatomic, weak) id<CollectionMenuControllerDelegate> delegate;
@property (nonatomic, strong) NSString *previousPlaylistTitle;

- (id)initWithRootView:(UIView *)view;

- (void)attachToView:(UIView *)view delegate:(id<MenuTargetDelegate>)menuTargetDelegate;
- (void)detachFromView:(UIView *)view;

@end

@protocol MenuTargetDelegate

- (SFMenuTarget *)menuTargetForLocation:(CGPoint)location;
- (void)didShowMenuAtLocation:(CGPoint)location inView:(UIView *)view;
- (void)willHideMenu;
- (void)didSelectMenuItem;

@end

@protocol CollectionMenuControllerDelegate

- (void)selectPlaylistForMediaItem:(id<SFMediaItem>)mediaItem;
- (void)extendPreviouslySelectedPlaylistByMediaItem:(id<SFMediaItem>)mediaItem;

@end
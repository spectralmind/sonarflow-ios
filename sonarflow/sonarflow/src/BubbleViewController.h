#import <Foundation/Foundation.h>

@protocol BubbleViewControllerDelegate;
@protocol SFMediaItem;
@protocol SFMediaLibrary;
@class BubbleFactory;
@class SFBubbleHierarchyView;
@class AppFactory;
@class DiscoveryZone;
@class GANHelper;

@interface BubbleViewController : NSObject

- (id)initWithLibrary:(NSObject<SFMediaLibrary> *)theLibrary factory:(AppFactory *)factory;

@property (nonatomic, strong) BubbleFactory *bubbleFactory;
@property (nonatomic, strong) SFBubbleHierarchyView *view;

@property (nonatomic, weak) id<BubbleViewControllerDelegate> delegate;

@property (nonatomic, strong) GANHelper *ganHelper;

-  (void)updatedDiscoveryZone:(DiscoveryZone *)newContents;

@end

@protocol BubbleViewControllerDelegate <NSObject>

- (void)tappedMediaItem:(id<SFMediaItem>)mediaItem inRect:(CGRect)rect;
- (void)doubleTappedMediaItem:(id<SFMediaItem>)mediaItem inRect:(CGRect)rect;

- (void)tappedEmptyLocation:(CGPoint)location;
- (void)discoveryInProgress:(BOOL)active;
- (void)updateArtistInFocus:(NSString *)artistName;

@end
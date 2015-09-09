#import <UIKit/UIKit.h>
#import "BubbleDataSource.h"

@class Bubble;
@class DataSourceProxy;
@class BubbleViewFactory;
@class BubbleMainView;
@class MainViewDelegate;
@class BVResources;
@class DiscoveryZone;

@protocol BubbleHierarchyViewDelegate;

/*!
 @class BubbleHierarchyView
 
 @abstract An BubbleHierarchyView object is a view which can display a zoomable hierarchy in form of bubbles.
 
 @discussion All configuration properites must be set before adding any bubbles.
 */
@interface BubbleHierarchyView : UIScrollView <UIScrollViewDelegate>

//Configuration properites - must be set before adding any bubbles

/*! 
 @property resources
 @abstract Object containing all bubble graphics and other visual configuration properties for these resources.
 @discussion Must be set before adding any bubbles.
 */
@property (nonatomic, strong) BVResources *resources;

/*! 
 @property bubbleTextFont
 @abstract Font for the title text of the bubbles.
 @discussion Must be set before adding any bubbles.
 */
@property (nonatomic, strong) UIFont *bubbleTextFont;

/*! 
 @property bubbleCountFont
 @abstract Font for the count number text of the bubbles.
 @discussion Must be set before adding any bubbles.
 */
@property (nonatomic, strong) UIFont *bubbleCountFont;

/*! 
 @property bubbleScreenSizeToShowChildren
 @abstract Maximum size of a parent bubble before its children are shown.
 @discussion Must be set before adding any bubbles.
 */
@property (nonatomic, assign) CGFloat bubbleScreenSizeToShowChildren;

/*! 
 @property bubbleScreenSizeToShowTitle
 @abstract Minimum size of a bubble at which its title text is shown.
 @discussion Must be set before adding any bubbles.
 */
@property (nonatomic, assign) CGFloat bubbleScreenSizeToShowTitle;

/*! 
 @property bubbleFadeSize
 @abstract Transistion zoom size of the dissolving transistion between hiding and showing the children bubbles.
 @discussion Must be set before adding any bubbles.
 */
@property (nonatomic, assign) CGFloat bubbleFadeSize;

/*! 
 @property coverSize
 @abstract Size of the cover image of a bubble.
 @discussion Must be set before adding any bubbles.
 */
@property (nonatomic, assign) CGSize coverSize;

/*! 
 @property showCountLabel
 @abstract Whether or not to show the count label.
 @discussion Must be set before adding any bubbles.
 */
@property (nonatomic, assign) BOOL showCountLabel;


/*! 
 @property bubbleContentInsets
 @abstract Outside area which should not be occupied by bubbles in the home position. Useful for overlay toolbars.
 @discussion Must be set before adding any bubbles.
 */
@property (nonatomic, assign) UIEdgeInsets bubbleContentInsets;


/*! 
 @property bubbleDelegate
 @abstract This instances BubbleHierarchyViewDelegate.
 @discussion Must be set before adding any bubbles.
 */
@property (nonatomic, weak) id<BubbleHierarchyViewDelegate> bubbleDelegate;

/*! 
 @property bubbleDataSource
 @abstract This instances BubbleDataSource.
 @discussion Must be set before adding any bubbles.
 */
@property (nonatomic, weak) id<BubbleDataSource> bubbleDataSource;


/*! 
 @property discoveryZoneCenterOffset
 @abstract Sets the center of the discovery zone. Can differ from the center of the whole bubbleview to take account for overlay toolbars or sidebars.
 */
@property (nonatomic, assign) CGPoint discoveryZoneCenterOffset;


/*!
 @method removeBubbleAtKeyPath:
 @abstract Removes a single bubble and its children.
 @param keyPath The keyPath of the bubble to remove. 
 */
- (void)removeBubbleAtKeyPath:(NSArray *)keyPath;

/*!
 @method reloadChildrenAtKeyPath:
 @abstract Reloads all child bubbles of the given keypath from the datasource.
 @param keyPath The keyPath to reload.
 */
- (void)reloadChildrenAtKeyPath:(NSArray *)keyPath;

- (void)reloadBubbleAtKeyPath:(NSArray *)keyPath;

/*!
 @method zoomOut
 @abstract Zooms out to the home position, showing all top-level bubbles.
 */
- (void)zoomOut;

/*!
 @method zoomToBubbleAtKeyPath:
 @abstract Zooms to the bubble at the given keyPath.
 @param keyPath The keyPath of the wanted bubble to zoom to.
 */
- (void)zoomToBubbleAtKeyPath:(NSArray *)keyPath;


/*!
 @method fadeOutBubbleHighlight
 @abstract Tapping a bubble highlights it. With this method the highlight can be faded out again.
 @discussion This is useful when showing some info in a popover or similar an let the highlight disappear when the popover is dismissed.
 */
- (void)fadeOutBubbleHighlight;


/*!
 @method startPlayingBubbleAtKeyPath:
 @abstract Starts a playing animation for the given bubble and all its parents.
 @param keyPath The keyPath of the bubble to start the playing animation for. 
 */
- (void)startPlayingBubbleAtKeyPath:(NSArray *)keyPath;

/*!
 @method pausePlayingBubbleAtKeyPath:
 @abstract Pauses a playing animation for the given bubble and all its parents.
 @param keyPath The keyPath of the bubble to pause the playing animation for. 
 */
- (void)pausePlayingBubbleAtKeyPath:(NSArray *)keyPath;

/*!
 @method setNothingPlaying
 @abstract Removes all playing animations.
 */
- (void)setNothingPlaying;


/*!
 @method adjustUIAfterOrientation
 @abstract Call this method after an interface orientation change has occured.
 */
- (void)adjustUIAfterOrientation;


/*!
 @method discoveryMode:
 @abstract Enters discovery mode and activates the discovery zone.
 @param enabled Whenter to enable or disable discovery mode. 
 */
- (void)discoveryMode:(BOOL)enabled;

/*!
 @method zoomInDemo
 @abstract Zooms in on the view to demo that pinch zoom is supported.
 */
- (void)zoomInDemo;

/*!
 @method rectForBubbleAtKeyPath:
 @abstract Fetches the rect for the visible bubble at the given keypath.
 @param keyPath The keyPath of the bubble to get the rect for.
 */
- (CGRect)rectForBubbleAtKeyPath:(NSArray *)keyPath;

@end


/*!
 @protocol BubbleHierarchyViewDelegate
 
 @abstract A BubbleHierarchyViewDelegate receives user interaction with bubbles.
 
 @discussion 
 
 tappedBubbleAtKeyPath:inRect: is called for single-taps on a bubble.
 
 doubleTappedBubbleAtKeyPath:inRect: is called for double-taps on a bubble.
 
 tappedEmptyLocation: is called for single-taps on an empty location between bubbles.

 updatedDiscoveryZone: is called when the area of the discovery mode changes.
 */
@protocol BubbleHierarchyViewDelegate <NSObject>

- (void)tappedBubbleAtKeyPath:(NSArray *)keyPath inRect:(CGRect)rect;
- (void)doubleTappedBubbleAtKeyPath:(NSArray *)keyPath inRect:(CGRect)rect;
- (void)tappedEmptyLocation:(CGPoint)location;
- (void)updatedDiscoveryZone:(DiscoveryZone *)newContents;
- (void)userZoomed;

@end
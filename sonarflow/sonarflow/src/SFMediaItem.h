#import <UIKit/UIKit.h>

@class MediaViewControllerFactory;
@class MPMediaItemArtwork;

@protocol SFMediaItem <NSObject>

@property (nonatomic, readonly, strong) id key;
@property (nonatomic, readonly, strong) NSString *name;
@property (nonatomic, readonly, strong) NSArray *children;
@property (nonatomic, readonly, weak) id<SFMediaItem> parent;
@property (nonatomic, readonly, strong) NSNumber *duration;

@required
- (BOOL)mayHaveChildren;
@optional
- (void)insertChildren:(NSArray *)newChildren atIndexes:(NSIndexSet *)indexes;
- (void)removeChildrenAtIndexes:(NSIndexSet *)indexes;
- (id<SFMediaItem>)childWithKey:(id)childKey;

- (BOOL)isEditable;
- (void)deleteChildAtIndex:(NSUInteger)index;
- (void)moveChildFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@optional
- (NSString *)artistName;

@required
- (BOOL)showAsBubble;
@optional
@property (nonatomic, readonly) UIColor *bubbleColor;
@property (nonatomic, readonly, assign) CGFloat relativeSize;

@required
- (BOOL)hasDetailViewController;
@optional
- (UIViewController *)createDetailViewControllerWithFactory:(MediaViewControllerFactory *)factory;
- (id<SFMediaItem>)allChildrenComposite;

@required
- (BOOL)mayHaveImage;
@optional
- (UIImage *)imageWithSize:(CGSize)size;
- (MPMediaItemArtwork *)artwork;

@required
- (void)startPlayback;
@optional
- (void)startPlaybackAtChildIndex:(NSUInteger)childIndex;

- (NSArray *)keyPath;

@optional
- (NSString *)countToShow;

@end

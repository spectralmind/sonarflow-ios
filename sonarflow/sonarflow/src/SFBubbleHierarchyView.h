#import "BubbleHierarchyView+Private.h"
#import "CollectionMenuController.h"

@protocol PlaylistEditor;
@protocol SFMediaItem;
@protocol SFBubbleHierarchyViewTrackDelegate;

@interface SFBubbleHierarchyView : BubbleHierarchyView <MenuTargetDelegate>

@property (nonatomic, weak) id<SFBubbleHierarchyViewTrackDelegate> trackDelegate;

- (void)attachPlaylistEditor:(NSObject<PlaylistEditor> *)playlistEditor;
- (void)detachPlaylistEditor:(NSObject<PlaylistEditor> *)playlistEditor;

@end


// TODO: Replace with direct reference to library?
@protocol SFBubbleHierarchyViewTrackDelegate <NSObject>

- (NSObject<SFMediaItem> *)mediaItemForKeyPath:(NSArray *)keyPath;

@end
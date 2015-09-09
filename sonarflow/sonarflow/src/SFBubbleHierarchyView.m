#import "SFBubbleHierarchyView.h"

#import "BubbleMainView.h"
#import "BubbleView.h"
#import "PlaylistEditor.h"
#import "UIDevice+SystemVersion.h"
#import "BVResources.h"
#import "SFMenuTarget.h"

#define kLabelBackgroundLeftCap 10
#define kLabelCountbackgroundLeftCap 8

@implementation SFBubbleHierarchyView

- (id)initWithFrame:(CGRect)theFrame {
    self = [super initWithFrame:theFrame];
    if (self) {
		[self initSFBubbleHierarchyView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
	
	[self initSFBubbleHierarchyView];
}

- (void)initSFBubbleHierarchyView {
	BVResources *resources = [[BVResources alloc] initWithLabelBackground:[UIImage imageNamed:@"bubble_text_background.png"]
												labelBackgroundLeftCapWidth:kLabelBackgroundLeftCap
													   labelCountBackground:[UIImage imageNamed:@"bubble_count_background.png"]
										   labelCoundBackgroundLeftCapWidth:kLabelCountbackgroundLeftCap
																	   glow:[UIImage imageNamed:@"bubble_glow_256.png"]
															   rimIndicator:[UIImage imageNamed:@"bubble_playing_512.png"]];
	[resources setBubbleBackgrounds:[self bubbleBackgroundImages] forType:BubbleTypeDefault];
	[resources setBubbleBackgrounds:[self discoveredBubbleBackgroundImages] forType:BubbleTypeDiscovered];
	self.resources = resources;
}

- (NSArray *)bubbleBackgroundImages {
	return [NSArray arrayWithObjects:
			[UIImage imageNamed:@"bubble_256.png"],
			[UIImage imageNamed:@"bubble_128.png"],
			[UIImage imageNamed:@"bubble_64.png"],
			[UIImage imageNamed:@"bubble_32.png"],
			nil];
}

- (NSArray *)discoveredBubbleBackgroundImages {
	return [NSArray arrayWithObject:[UIImage imageNamed:@"similar_128.png"]];
}


#pragma mark Methods

- (void)attachPlaylistEditor:(NSObject<PlaylistEditor> *)playlistEditor {
	[playlistEditor attachToView:self.bubbleMainView delegate:self];
}

- (void)detachPlaylistEditor:(NSObject<PlaylistEditor> *)playlistEditor {
	[playlistEditor detachFromView:self.bubbleMainView];
}


#pragma mark MenuTargetDelegate

- (SFMenuTarget *)menuTargetForLocation:(CGPoint)location {
	BubbleView *bubbleView = [self.bubbleMainView bubbleViewForLocation:location];
	if(bubbleView.bubble.type != BubbleTypeDefault) {
		return nil;
	}
	
	return [SFMenuTarget menuTargetWithMediaItem:[self.trackDelegate mediaItemForKeyPath:[bubbleView keyPath]]
									boundingRect:[self.bubbleMainView convertRect:bubbleView.bounds fromView:bubbleView]];
}

- (void)didShowMenuAtLocation:(CGPoint)location inView:(UIView *)view {
	CGPoint mainViewLocation = [self.bubbleMainView convertPoint:location fromView:view];
	[self.bubbleMainView startHighlightingBubbleAtLocation:mainViewLocation];
	self.bubbleMainView.ignoreNextTap = YES;
}

- (void)willHideMenu {
	[self fadeOutBubbleHighlight];
}

- (void)didSelectMenuItem {
	self.bubbleMainView.ignoreNextTap = NO;
}

@end

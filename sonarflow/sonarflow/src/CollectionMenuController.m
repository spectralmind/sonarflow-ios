#import "CollectionMenuController.h"

#import "CollectionMenuTarget.h"
#import "NSString+Truncate.h"
#import "SFMediaItem.h"
#import "SFMenuTarget.h"

#define kNumDefaultMenuItems 2
#define kMaxPlaylistTitleLength 10

@interface CollectionMenuController () <MenuCommands>

@property (nonatomic, strong) UIView *menuResponder;
@property (nonatomic, strong) NSArray *defaultMenuItems;
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, weak) id<MenuTargetDelegate> currentTargetDelegate;
@property (nonatomic, assign) CGPoint targetLocation;
@property (nonatomic, strong) SFMenuTarget *currentTarget;

@end

@implementation CollectionMenuController {
	UIView *menuResponder;
	NSMutableArray *targets;
	
	NSArray *defaultMenuItems;
	NSArray *menuItems;
	
	id<CollectionMenuControllerDelegate> __weak delegate;
	NSString *previousPlaylistTitle;
	
	id<MenuTargetDelegate> currenTarget;
	CGPoint targetLocation;
}

- (id)initWithRootView:(UIView *)view {
	self = [super init];
	if(self) {
		[self createMenuResponderInView:view];
		targets = [[NSMutableArray alloc] initWithCapacity:3];
		[self createMenuNotificationListeners];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[menuResponder removeFromSuperview];
}

@synthesize delegate;
@synthesize previousPlaylistTitle;
@synthesize menuResponder;
@synthesize defaultMenuItems;
@synthesize menuItems;
@synthesize currentTargetDelegate;
@synthesize targetLocation;
@synthesize currentTarget;

- (void)createMenuResponderInView:(UIView *)view {
	MenuResponder *responder = [[MenuResponder alloc] initWithFrame:CGRectZero];
	responder.delegate = self;
	[view addSubview:responder];
	
	self.menuResponder = responder;
}

- (void)createMenuNotificationListeners {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideEditMenu:) name:UIMenuControllerWillHideMenuNotification object:nil];
}

- (void)willHideEditMenu:(NSNotification *)notification {
	[self.currentTargetDelegate willHideMenu];
}

- (void)attachToView:(UIView *)view delegate:(id<MenuTargetDelegate>)menuTargetDelegate {
	NSAssert([self indexOfTargetView:view] == NSNotFound,
			 @"CollectionMenuController: Already attached to view");
	
	UILongPressGestureRecognizer *gestureRecognizer = [self createGestureRecognizer];
	for(UIGestureRecognizer *otherRecognizer in view.gestureRecognizers) {
		if([otherRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
			[otherRecognizer requireGestureRecognizerToFail:gestureRecognizer];
		}
	}
	[view addGestureRecognizer:gestureRecognizer];
	
	CollectionMenuTarget *target = [[CollectionMenuTarget alloc] init];
	target.view = view;
	target.delegate = menuTargetDelegate;
	target.gestureRecognizer = gestureRecognizer;
	[targets addObject:target];
}

- (UILongPressGestureRecognizer *)createGestureRecognizer {
	return [[UILongPressGestureRecognizer alloc] initWithTarget:self
		action:@selector(handleLongPressGesture:)];
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer {
	UIGestureRecognizerState state = [gestureRecognizer state];
    if(state != UIGestureRecognizerStateBegan) {
		return;
	}
	
	UIView *targetView = gestureRecognizer.view;
	self.currentTargetDelegate = [self delegateForView:targetView];
	CGPoint location = [gestureRecognizer locationInView:targetView];
	self.currentTarget = [self.currentTargetDelegate menuTargetForLocation:location];
	if(self.currentTarget == nil) {
		[self cancelGestureRecognizer:gestureRecognizer];
		return;
	}

	[self.menuResponder becomeFirstResponder];
	if([self.menuResponder isFirstResponder]) {
		self.targetLocation = location;
		[self showForTargetRect:self.currentTarget.boundingRect location:location inView:targetView];
	}
}

- (id<MenuTargetDelegate>)delegateForView:(UIView *)view {
	NSUInteger targetIndex = [self indexOfTargetView:view];
	NSAssert(targetIndex != NSNotFound, @"Missing target for gesture recognizer");
	CollectionMenuTarget *target = [targets objectAtIndex:targetIndex];
	return target.delegate;
}
	   
- (void)cancelGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
	gestureRecognizer.enabled = NO;
	gestureRecognizer.enabled = YES;
}

- (void)detachFromView:(UIView *)view {
	NSInteger targetIndex = [self indexOfTargetView:view];
	NSAssert(targetIndex != NSNotFound, @"CollectionMenuController: Not attached to view");
	
	CollectionMenuTarget *target = [targets objectAtIndex:targetIndex];
	[target.view removeGestureRecognizer:target.gestureRecognizer];
	[targets removeObjectAtIndex:targetIndex];
}

- (NSInteger)indexOfTargetView:(UIView *)view {
	for(NSInteger i = 0; i < [targets count]; ++i) {
		CollectionMenuTarget *target = [targets objectAtIndex:i];
		if(target.view == view) {
			return i;
		}
	}
	return NSNotFound;
}

- (void)setPreviousPlaylistTitle:(NSString *)newTitle {
	if(previousPlaylistTitle != newTitle) {
		previousPlaylistTitle = newTitle;
		[self createMenuItems];
	}
}

- (void)createMenuItems {
	NSArray *newItems = [self defaultMenuItems];
	if(self.previousPlaylistTitle != nil) {
		newItems = [newItems arrayByAddingObject:[self previousPlaylistMenuItem]];
	}
	self.menuItems = newItems;//[newItems arrayByAddingObject:<#(id)anObject#>
}

- (NSArray *)defaultMenuItems {
	if(defaultMenuItems == nil) {
		[self createDefaultMenuItems];
	}
	
	return defaultMenuItems;
}

- (void)createDefaultMenuItems {
	NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:2];

	NSString *playTitle = NSLocalizedString(@"Play",
											@"Title for menu item that starts playback");
	UIMenuItem *play = [[UIMenuItem alloc] initWithTitle:playTitle action:@selector(play)];
	[result addObject:play];

#ifndef SF_SPOTIFY
	NSString *addTitle = NSLocalizedString(@"Add to playlist…",
										   @"Title for menu item that adds tracks to a playlist");
	UIMenuItem *addItem = [[UIMenuItem alloc] initWithTitle:addTitle action:@selector(addToPlaylist)];
	[result addObject:addItem];
#endif

	defaultMenuItems = result;
}

- (UIMenuItem *)previousPlaylistMenuItem {
	NSString *addFormat = NSLocalizedString(@"Add to '%@'",
											@"Title for menu item that adds tracks to a specific playlist");
	NSString *playlistTitle = [self.previousPlaylistTitle stringByTruncatingMiddleToLength:kMaxPlaylistTitleLength];
	NSString *title = [NSString stringWithFormat:addFormat,
					   playlistTitle];
	return [[UIMenuItem alloc] initWithTitle:title action:@selector(addToPreviousPlaylist)];
}

- (void)showForTargetRect:(CGRect)rect location:(CGPoint)location inView:(UIView *)view {
	UIMenuController *menuController = [self configuredMenuController];
	[menuController setTargetRect:rect inView:view];
	[menuController setMenuVisible:YES animated:YES];
	[self.currentTargetDelegate didShowMenuAtLocation:location inView:view];
}

- (UIMenuController *)configuredMenuController {
	if(self.menuItems == nil) {
		[self createMenuItems];
	}

	UIMenuController *menuController = [UIMenuController sharedMenuController];
	menuController.menuItems = self.menuItems;
	return menuController;
}

#pragma mark -
#pragma mark MenuCommands

- (void)play {
	[self.currentTargetDelegate didSelectMenuItem];
	[self.currentTarget.mediaItem startPlayback];
}

- (void)addToPlaylist {
	[self.currentTargetDelegate didSelectMenuItem];
	[self.delegate selectPlaylistForMediaItem:self.currentTarget.mediaItem];
}

- (void)addToPreviousPlaylist {
	[self.currentTargetDelegate didSelectMenuItem];
	[self.delegate extendPreviouslySelectedPlaylistByMediaItem:self.currentTarget.mediaItem];
}


@end

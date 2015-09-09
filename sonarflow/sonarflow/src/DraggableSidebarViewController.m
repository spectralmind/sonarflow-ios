#import "DraggableSidebarViewController.h"

#ifdef TESTFLIGHT
	#import "TestFlight.h"
#endif


@implementation DraggableSidebarViewController {
	CGRect originalFrame;
	CGRect frameAtDragStart;

	UIImageView *handle;
	UIView *contentView;
	
	BOOL isFullscreen;
}

- (void)setSidebarController:(UIViewController *)theSidebarController {
	if(theSidebarController == _sidebarController) {
		return;
	}
	
	[_sidebarController.view removeFromSuperview];
	[_sidebarController removeFromParentViewController];
	
	_sidebarController = theSidebarController;
	
	[self enslaveViewController:_sidebarController];
}

- (void)setFullscreenController:(UIViewController *)theFullscreenController {
	if(theFullscreenController == _fullscreenController) {
		return;
	}
	
	[_fullscreenController.view removeFromSuperview];
	[_fullscreenController removeFromParentViewController];
	
	_fullscreenController = theFullscreenController;
	
	[self enslaveViewController:_fullscreenController];
}


- (void)enslaveViewController:(UIViewController *)child {
	
	if(child == nil) {
		return;
	}

	[self addChildViewController:child];
	[contentView addSubview:child.view];
	[child didMoveToParentViewController:self];
	
	child.view.opaque = NO;	
}


#define kGripWidthMakeup	40.0

- (void)loadView {
	
	const CGRect referenceRect = CGRectMake(0, 0, 100, 100);
	UIView *v = [[UIView alloc] initWithFrame:referenceRect];
	v.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
	
	handle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"handle"]];
	CGRect frame = handle.frame;
	CGFloat handleWidth = frame.size.width;
	frame.size.width += kGripWidthMakeup;
	handle.frame = frame;
	handle.center = CGPointMake(CGRectGetMidX(handle.bounds)-kGripWidthMakeup/2, referenceRect.size.height/2);
	handle.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
	handle.contentMode = UIViewContentModeCenter;
	handle.userInteractionEnabled = YES;
	handle.multipleTouchEnabled = YES;
	
	UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
										  initWithTarget:self action:@selector(handlePanGesture:)];	
    [handle addGestureRecognizer:panGesture];

	CGRect contentFrame = referenceRect;
	contentFrame.origin.x = handleWidth;
	contentFrame.size.width = referenceRect.size.width - handleWidth;
	contentView = [[UIView alloc] initWithFrame:contentFrame];
	contentView.backgroundColor = [UIColor clearColor];
	contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
	[v addSubview:contentView];
	[v addSubview:handle];
	
	self.view = v;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self enslaveViewController:self.sidebarController];
	[self enslaveViewController:self.fullscreenController];

	isFullscreen = NO;
}

#define kBlendDistance 200.0

- (void)viewWillLayoutSubviews {	
	CGFloat x = self.view.frame.origin.x;
	float ratio;
	
	if(x < originalFrame.origin.x-kBlendDistance) {
		ratio = 1.0;
	}
	else if(x >= originalFrame.origin.x) {
		ratio = 0.0;
	}
	else {
		ratio = (originalFrame.origin.x-x)/kBlendDistance;
	}
	
	self.sidebarController.view.alpha = 1.0 - ratio;
	self.fullscreenController.view.alpha = ratio;
}

- (void)viewDidAppear:(BOOL)animated {
	if (isFullscreen) {
		return;
	}
	
	originalFrame = self.view.frame;
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender {	
    CGPoint translate = [sender translationInView:self.view];	

	switch(sender.state) {
		case UIGestureRecognizerStateEnded:
		case UIGestureRecognizerStateCancelled:
			[self dragEndedWithOffset:translate.x];
			break;
		
		case UIGestureRecognizerStateBegan:
			frameAtDragStart = self.view.frame;

			/* FALL THROUGH */
			
		case UIGestureRecognizerStateChanged:
			do{}while(0); //LLVM BUG! REMOVE ASAP
			CGRect frame = frameAtDragStart;
			if([self canDragToOffset:translate.x]) {
				frame.origin.x += translate.x;
				frame.size.width -= translate.x;
			}
			
			self.view.frame = frame;
			
			break;
			
		default:
			break;
	}
}

- (BOOL)canDragToOffset:(CGFloat)offset {	
	if(frameAtDragStart.origin.x + offset >= originalFrame.origin.x) {
		return NO;
	}
		
	return YES;
}

- (void)dragEndedWithOffset:(CGFloat)offset {
	
	BOOL fullscreen = NO;
	
	if([self canDragToOffset:offset] && isFullscreen == NO) {
		fullscreen = YES;
#ifdef TESTFLIGHT
		[TestFlight passCheckpoint:@"sidebar:draggedToFullscreen"];
#endif
	}

	[self fullscreen:fullscreen];
}

- (void)fullscreen:(BOOL)enableFullscreen {
	
	CGRect target = enableFullscreen ? self.fullscreenRect : originalFrame;
	isFullscreen = enableFullscreen;
	
	[UIView animateWithDuration:1.0 animations:^{
		self.view.frame = target;
	}];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// deprecated in iOS 6
	return YES;
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}


#pragma mark - OverlayCloseRequestDelegate methods

- (void)dismissOverlay:(UIViewController *)presentedViewController {
	if(isFullscreen) {
		[self dragEndedWithOffset:0];
	}
}

@end

#import <UIKit/UIKit.h>

#import "ArtistInfoIpadViewController.h"

@interface DraggableSidebarViewController : UIViewController <OverlayCloseRequestDelegate> 
@property (nonatomic, strong) UIViewController *sidebarController;
@property (nonatomic, strong) UIViewController *fullscreenController;

@property (nonatomic, assign) CGRect fullscreenRect;

- (void)fullscreen:(BOOL)enableFullscreen;

@end

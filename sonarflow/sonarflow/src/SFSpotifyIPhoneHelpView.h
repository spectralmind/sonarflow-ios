#import <UIKit/UIKit.h>

#import "SFIPhoneHelpView.h"

@interface SFSpotifyIPhoneHelpView : UIView <SFIPhoneHelpView, UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;

@property (nonatomic, weak) IBOutlet UIView *page1;
@property (nonatomic, weak) IBOutlet UIView *page2;
@property (nonatomic, weak) IBOutlet UIView *page3;
@property (nonatomic, weak) IBOutlet UIView *help11;
@property (nonatomic, weak) IBOutlet UIView *help12;
@property (nonatomic, weak) IBOutlet UIView *help13;
@property (nonatomic, weak) IBOutlet UIView *help14;
@property (nonatomic, weak) IBOutlet UIView *help21;
@property (nonatomic, weak) IBOutlet UIView *help22;
@property (nonatomic, weak) IBOutlet UIView *help23;
@property (nonatomic, weak) IBOutlet UIView *help24;
@property (nonatomic, weak) IBOutlet UIView *help31;
@property (nonatomic, weak) IBOutlet UIView *help32;
@property (nonatomic, weak) IBOutlet UIView *help34;
@property (nonatomic, weak) IBOutlet UIView *page4;

- (IBAction)changePage:(id)sender;

@end

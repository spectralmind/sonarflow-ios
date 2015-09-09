#import <UIKit/UIKit.h>

@class SFSmartistFactory;
@protocol ArtistSharingDelegate;

@interface ArtistInfoViewController : UIViewController

@property (nonatomic, strong) NSString *artistName;

@property (nonatomic, strong) id<ArtistSharingDelegate> sharingDelegate;

@property (weak, nonatomic, readonly) UIButton *facebookButton;
@property (weak, nonatomic, readonly) UIButton *twitterButton;

@property (nonatomic, assign) BOOL updateWhenViewAppearsNextTime;

- (void)useSmartistInstanceFromFactory:(SFSmartistFactory *)factory;
- (void)updateContents;

@end
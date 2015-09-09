#import <UIKit/UIKit.h>

@class MainViewController;

@interface SonarflowAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;

@property (nonatomic, strong) IBOutlet UIViewController *rootViewController;
@property (nonatomic, strong) IBOutlet MainViewController *viewController;

- (NSString *)applicationDocumentsDirectory;

@end
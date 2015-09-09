#import <Foundation/Foundation.h>

@protocol AppStatusObserverDelegate;

@interface AppStatusObserver : NSObject

@property (nonatomic, weak) NSObject<AppStatusObserverDelegate> *delegate;

- (id)init;
- (id)initWithBecomeActiveDelay:(NSTimeInterval)delay;

@end

@protocol AppStatusObserverDelegate

@optional
- (void)appWillResignActive;
- (void)appDidEnterBackground;
- (void)appWillEnterForeground;
- (void)appDidBecomeActive;

@end
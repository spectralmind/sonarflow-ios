#import <Foundation/Foundation.h>

@interface SFTimeTracker : NSObject

@property (nonatomic, assign, getter = isActive) BOOL active;

- (void)reset;

- (NSTimeInterval)duration;


@end

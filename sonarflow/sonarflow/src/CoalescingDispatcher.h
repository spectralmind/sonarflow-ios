#import <Foundation/Foundation.h>

typedef void(^CoalescedBlock)();

@interface CoalescingDispatcher : NSObject

- (id)initWithPeriod:(NSTimeInterval)thePeriod block:(CoalescedBlock)theBlock;


- (void)fireAfterPeriod;

@end

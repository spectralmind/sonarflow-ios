#import <Foundation/Foundation.h>

typedef id (^RealizeBlock) (void);
typedef void (^FaultBlock) (id);

@interface Faulter : NSObject {
	RealizeBlock realizeBlock;
	FaultBlock faultBlock;
	
	NSDate *faultDelayStart;
	id element;
	BOOL isRealizing;
}

- (id)initWithRealizeBlock:(RealizeBlock)theRealizeBlock faultBlock:(FaultBlock)theFaultBlock;

@property (nonatomic, readonly, strong) id element;

- (BOOL)isFault;
- (BOOL)couldBecomeFault;

- (void)allowFaulting;

@end

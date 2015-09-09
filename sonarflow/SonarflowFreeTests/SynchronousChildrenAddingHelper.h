#import <Foundation/Foundation.h>

@interface SynchronousChildrenAddingHelper : NSObject

+ (void (^)(NSInvocation *))synchronousChildrenAddingBlock;

@end

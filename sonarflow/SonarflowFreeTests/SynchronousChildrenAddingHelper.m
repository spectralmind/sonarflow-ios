#import "SynchronousChildrenAddingHelper.h"

#import "CollectionWithChildren.h"

@implementation SynchronousChildrenAddingHelper

+ (void (^)(NSInvocation *))synchronousChildrenAddingBlock {
	return ^(NSInvocation *invocation) {
		__unsafe_unretained CollectionWithChildren *collection = nil;
		[invocation getArgument:&collection atIndex:0];
		__unsafe_unretained NSArray *children = nil;
		[invocation getArgument:&children atIndex:2];
		[collection insertChildren:children atIndexes:nil];
	};
}

@end

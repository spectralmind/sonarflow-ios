#import <Foundation/Foundation.h>

#import "Bubble.h"

@interface RootKey : NSObject

- (id)initWithKey:(id)theKey type:(BubbleType)theType;
+ (id)rootKeyWithKey:(id)theKey type:(BubbleType)theType;

@property (nonatomic, readonly) id key;
@property (nonatomic, readonly) BubbleType type;

@end

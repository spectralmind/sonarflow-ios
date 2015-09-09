#import <Foundation/Foundation.h>

#import "SFMediaItem.h"

@interface SFTestMediaItem : NSObject <SFMediaItem>

- (id)initWithKey:(id)theKey;

@property (nonatomic, readwrite, strong) NSString *name;
@property (nonatomic, readwrite, strong) NSArray *children;
@property (nonatomic, readwrite, weak) id<SFMediaItem> parent;
@property (nonatomic, readwrite, strong) NSNumber *duration;

- (SFTestMediaItem *)addChildWithKey:(id)aKey;
- (void)addChild:(SFTestMediaItem *)child;
- (void)removeChild:(SFTestMediaItem *)child;

- (NSUInteger)totalSize;

@end

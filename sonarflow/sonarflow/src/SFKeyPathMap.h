#import <Foundation/Foundation.h>

@interface SFKeyPathMap : NSObject

- (id)objectForKeyPath:(NSArray *)keyPath;
- (void)setObject:(id)object forKeyPath:(NSArray *)keyPath;
- (void)removeObjectsForKeyPath:(NSArray *)keyPath;
- (void)removeChildrenOfKeyPath:(NSArray *)keyPath;
- (void)removeAllObjects;

@end

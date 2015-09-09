#import <Foundation/Foundation.h>

@interface NSArray (KeyPath)

- (id)head;
- (NSArray *)tail;

- (BOOL)hasParent;
- (NSArray *)parent;

@end

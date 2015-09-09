#import <Foundation/Foundation.h>

@interface BubbleViewTestHelper : NSObject {
	id viewFactoryMock;
	NSMutableDictionary *viewsByKey;
}

@property (nonatomic, readonly) id viewFactoryMock;
@property (nonatomic, readonly) id dataSourceMock;

- (id)init;

- (id)bubbleMockWithKey:(id)key;
- (void)setChildBubbles:(NSArray *)childBubbles forParentKeyPath:(NSArray *)keyPath;
- (id)viewMockForKey:(id)key;

@end

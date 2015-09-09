#import <UIKit/UIKit.h>

@class Bubble;

/*!
 @protocol BubbleDataSource
 
 @abstract A BubbleDataSource provides the data about bubbles which is needed to draw them on screen.
 
 @discussion 
 
 coverForKeyPath: asks for the cover image of the bubble with the given keyPath.
 
 childrenForKeyPath: asks for the child bubbles of the bubble with the given keyPath.
 */
@protocol BubbleDataSource <NSObject>

- (UIImage *)coverForKeyPath:(NSArray *)keyPath;

/// Return nil if the children are not yet known or an empty array if there are no children.
- (NSArray *)childrenForKeyPath:(NSArray *)keyPath;
- (Bubble *)bubbleForKeyPath:(NSArray *)keyPath;

@end

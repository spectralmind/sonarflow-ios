#import <Foundation/Foundation.h>
#import "BubbleMainView.h"

@class BubbleHierarchyView;

@interface MainViewDelegate : NSObject <BubbleMainViewDelegate> {
	BubbleHierarchyView *view;
}

- (id)initWithView:(BubbleHierarchyView *)theView;

@end

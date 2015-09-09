#import <Foundation/Foundation.h>

@protocol MenuTargetDelegate;

@interface CollectionMenuTarget : NSObject

@property (nonatomic, strong) UIView *view;
@property (nonatomic, weak) id<MenuTargetDelegate> delegate;
@property (nonatomic, strong) UIGestureRecognizer *gestureRecognizer;

@end

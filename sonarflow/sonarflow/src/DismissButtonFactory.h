#import <Foundation/Foundation.h>

@interface DismissButtonFactory : NSObject

- (UIBarButtonItem *)doneButtonForViewController:(UIViewController *)controller;
- (UIBarButtonItem *)cancelButtonForViewController:(UIViewController *)controller;
- (UIBarButtonItem *)closeButtonForViewController:(UIViewController *)controller;

@end

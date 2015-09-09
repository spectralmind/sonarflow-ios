#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UIImage (Stretchable)

+ (UIImage *)stretchableImageNamed:(NSString *)imageName leftCapWidth:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight;

@end

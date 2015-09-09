#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (CGLogging)

+ (NSString *)stringFromRect:(CGRect)rect;
+ (NSString *)stringFromPoint:(CGPoint)point;
+ (NSString *)stringFromSize:(CGSize)size;

@end

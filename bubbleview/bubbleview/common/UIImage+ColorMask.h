#import <UIKit/UIKit.h>

@interface UIImage (ColorMask)

+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color;

// calculates an image from the current image that is tinted with the given color
// acts like "color" layer mode in photoshop
//     only uses luminosity of original image and replaces hue and saturation from given color
//     original image can be in color
// preserves alpha channel
// white stays white
// black stays black
- (UIImage *)imageWithColor:(UIColor *)color;

// calculates an image from the current image that is tinted with the given color
// acts like "multiply" layer mode in photoshop
//     multiplies every pixel of original image with given color
//     original image must be in grey scale to correctly tint
// preserves alpha channel
// white becomes given color
// black stays black
- (UIImage *)imageWithMultipliedColor:(UIColor *)color;

// calculates an image with given color from alpha channel of original image
- (UIImage *)imageUsingAlphachannelWithColor:(UIColor *)color;


@end

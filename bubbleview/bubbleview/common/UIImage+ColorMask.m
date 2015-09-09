#import "UIImage+ColorMask.h"

@implementation UIImage (ColorMask)

+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color {
	UIImage *image = [UIImage imageNamed:name];
	return [image imageWithColor:color];
}

- (UIImage *)imageWithColor:(UIColor *)color {
	UIGraphicsBeginImageContext(self.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextTranslateCTM(context, 0, self.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
	
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [[UIColor blackColor] setFill];
    CGContextFillRect(context, rect);
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, self.CGImage);
    
    CGContextSetBlendMode(context, kCGBlendModeColor);
    [color setFill];
    CGContextFillRect(context, rect);
	
    CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
    CGContextDrawImage(context, rect, self.CGImage);
	
	UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return coloredImage;
}

- (UIImage *)imageWithMultipliedColor:(UIColor *)color {
	UIGraphicsBeginImageContext(self.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextTranslateCTM(context, 0, self.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
	
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [[UIColor blackColor] setFill];
    CGContextFillRect(context, rect);

    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, self.CGImage);
    
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    [color setFill];
    CGContextFillRect(context, rect);
	
    CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
    CGContextDrawImage(context, rect, self.CGImage);
	
	UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return coloredImage;
}

- (UIImage *)imageUsingAlphachannelWithColor:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
	[self drawAtPoint:CGPointZero];

	CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGContextTranslateCTM(context, 0, self.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    
	CGContextSetBlendMode(context, kCGBlendModeMultiply);
	CGContextClipToMask(context, rect, self.CGImage);
	CGContextSetFillColorWithColor(context, color.CGColor);
	CGContextFillRect(context, rect);
		
	UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return coloredImage;
}

@end

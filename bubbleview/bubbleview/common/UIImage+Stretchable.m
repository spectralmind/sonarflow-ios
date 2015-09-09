#import "UIImage+Stretchable.h"


@implementation UIImage (Stretchable)

+ (UIImage *)stretchableImageNamed:(NSString *)imageName leftCapWidth:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight {
	UIImage *image = [UIImage imageNamed:imageName];
	return [image stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
}

@end

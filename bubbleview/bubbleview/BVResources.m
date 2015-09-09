#import "BVResources.h"
#import "BVResources+Private.h"
#import "UIImage+ColorMask.h"

@implementation BVResources {
	NSMutableDictionary *bubbleBackgroundImagesPerType;
	NSMutableDictionary *bubbleBackgroundSizesPerType;
	UIImage *labelBackgroundImage;
	NSUInteger labelBackgroundLeftCapWidth;
	UIImage *labelCountBackground;
	NSUInteger labelCoundBackgroundLeftCapWidth;
	
	UIImage *glowImage;
	UIImage *rimIndicatorImage;
	
	NSMutableDictionary *bubbleBackgroundsByColorByType;
	NSMutableDictionary *labelBackgroundByColor;
}

- (id)initWithLabelBackground:(UIImage *)theLabelBackgroundImage labelBackgroundLeftCapWidth:(NSUInteger)theLabelBackgroundLeftCapWidth labelCountBackground:(UIImage *)theLabelCountBackgroundImage labelCoundBackgroundLeftCapWidth:(NSUInteger)theLabelCountBackgroundLeftCapWidth glow:(UIImage *)theGlowImage rimIndicator:(UIImage *)theRimIndicatorImage {
    self = [super init];
    if (self) {
		bubbleBackgroundImagesPerType = [[NSMutableDictionary alloc] initWithCapacity:2];
		bubbleBackgroundSizesPerType = [[NSMutableDictionary alloc] initWithCapacity:2];
		labelBackgroundImage = [theLabelBackgroundImage stretchableImageWithLeftCapWidth:theLabelBackgroundLeftCapWidth topCapHeight:0];
		labelBackgroundLeftCapWidth = theLabelBackgroundLeftCapWidth;
		labelCountBackground = [theLabelCountBackgroundImage stretchableImageWithLeftCapWidth:theLabelCountBackgroundLeftCapWidth topCapHeight:0];
		labelCoundBackgroundLeftCapWidth = theLabelCountBackgroundLeftCapWidth;
		
		glowImage = theGlowImage;
		rimIndicatorImage = theRimIndicatorImage;

		bubbleBackgroundsByColorByType = [[NSMutableDictionary alloc] initWithCapacity:2];
        labelBackgroundByColor = [[NSMutableDictionary alloc] initWithCapacity:15];
    }
    return self;
}


@synthesize labelBackgroundImage;
@synthesize labelCountBackgroundImage = labelCountBackground;
@synthesize glowImage;
@synthesize rimIndicatorImage;

- (void)setBubbleBackgrounds:(NSArray *)theBubbleBackgroundImages forType:(BubbleType)type {
	id typeKey = [self keyForType:type];
	[bubbleBackgroundImagesPerType setObject:theBubbleBackgroundImages forKey:typeKey];
	[bubbleBackgroundSizesPerType setObject:[self sizesOfImages:theBubbleBackgroundImages] forKey:typeKey];
}

- (id)keyForType:(BubbleType)type {
	return [NSNumber numberWithInt:type];
}

- (NSArray *)sizesOfImages:(NSArray *)images {
	NSMutableArray *sizes = [NSMutableArray arrayWithCapacity:[images count]];
	for(UIImage *image in images) {
		NSNumber *size = [NSNumber numberWithFloat:[image size].width];
		[sizes addObject:size];
	}
	return sizes;
}

- (NSArray *)bubbleBackgroundSizesForType:(BubbleType)type {
	return [bubbleBackgroundSizesPerType objectForKey:[self keyForType:type]];
}

- (NSArray *)bubbleBackgroundsForType:(BubbleType)type color:(UIColor *)color {
	id colorKey = [self keyForColor:color];
	NSMutableDictionary *bubbleBackgroundsByColor = [bubbleBackgroundsByColorByType objectForKey:[self keyForType:type]];
	if(bubbleBackgroundsByColor == nil) {
		bubbleBackgroundsByColor = [NSMutableDictionary dictionaryWithCapacity:15];
		[bubbleBackgroundsByColorByType setObject:bubbleBackgroundsByColor forKey:[self keyForType:type]];
	}
	NSArray *images = [bubbleBackgroundsByColor objectForKey:colorKey];
	if(images == nil) {
		images = [self createBubbleBackgroundsForType:type color:color];
		[bubbleBackgroundsByColor setObject:images forKey:colorKey];
	}
	return images;
}

- (NSArray *)createBubbleBackgroundsForType:(BubbleType)type color:(UIColor *)color {
	NSArray *bubbleBackgroundImages = [bubbleBackgroundImagesPerType objectForKey:[self keyForType:type]];
	NSMutableArray *coloredImages = [NSMutableArray arrayWithCapacity:[bubbleBackgroundImages count]];
	for(UIImage *image in bubbleBackgroundImages) {
		UIImage *coloredImage = [image imageUsingAlphachannelWithColor:color];
		[coloredImages addObject:coloredImage];
	}
	return coloredImages;
}

- (UIImage *)labelBackgroundForColor:(UIColor *)color {
	id colorKey = [self keyForColor:color];
	UIImage *image = [labelBackgroundByColor objectForKey:colorKey];
	if(image == nil) {
		image = [self createLabelBackgroundForColor:color];
		[labelBackgroundByColor setObject:image forKey:colorKey];
	}
	return image;
}

- (UIImage *)createLabelBackgroundForColor:(UIColor *)color {
	UIImage *coloredImage = [[labelBackgroundImage imageWithMultipliedColor:color] stretchableImageWithLeftCapWidth:labelBackgroundLeftCapWidth topCapHeight:0];
	return coloredImage;
}

- (id)keyForColor:(UIColor *)color {
	return [NSKeyedArchiver archivedDataWithRootObject:color];
}



@end

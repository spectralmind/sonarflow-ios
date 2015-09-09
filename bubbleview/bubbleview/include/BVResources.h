#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "Bubble.h"

/*!
 @class BVResources
 
 @abstract An BVResources object contains all bubble graphics and other visual configuration properties for these resources.
 */
@interface BVResources : NSObject

/*!
 @method initWithLabelBackground:labelBackgroundLeftCapWidth:labelCountBackground:labelCoundBackgroundLeftCapWidth:glow:rimIndicator:
 @abstract Initializes a BVResources object with the given graphics.
 */
- (id)initWithLabelBackground:(UIImage *)theLabelBackgroundImage labelBackgroundLeftCapWidth:(NSUInteger)theLabelBackgroundLeftCapWidth labelCountBackground:(UIImage *)theLabelCountBackgroundImage labelCoundBackgroundLeftCapWidth:(NSUInteger)theLabelCountBackgroundLeftCapWidth glow:(UIImage *)theGlowImage rimIndicator:(UIImage *)theRimIndicatorImage;

/*!
 @method setBubbleBackgrounds:forType:
 @abstract Sets the bubble background images for the given bubble type.
 @param theBubbleBackgroundImages An array of images of different sizes of the same bubble background graphic.
 @param type The bubble type these images should be used for.

 */
- (void)setBubbleBackgrounds:(NSArray *)theBubbleBackgroundImages forType:(BubbleType)type;

@end

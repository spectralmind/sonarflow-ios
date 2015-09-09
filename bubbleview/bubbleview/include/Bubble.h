#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol BubbleDataSource;

/*!
 @enum BubbleType
 @abstract The different bubble types.
 @discussion 
 */
typedef enum {
	BubbleTypeDefault = 0,
	BubbleTypeDiscovered
} BubbleType;

/*!
 @class Bubble
 
 @abstract A Bubble object represents the data model of a single bubble.
 */
@interface Bubble : NSObject <NSCopying>

/*!
 @method initWithKey:
 @abstract Initializes a Bubble with the given key.
 @discussion The key is retained by the bubble.
 @param theKey The key of this bubble which is used to refind it in the hierarchy via keyPath.
 @result The initialized Bubble instance.
 */
- (id)initWithKey:(id)theKey;

/*! 
 @property key
 @abstract A clientside unique identifier for this bubble.
 @discussion It needs to be guaranteed that the key is at least unique among the siblings.
 */
@property (nonatomic, readonly) id key;


/*! 
 @property origin
 @abstract Origin in space of this bubble.
 @discussion The origin is measured from the center bubble of the parent to this bubble's center.
 */
@property (nonatomic, assign) CGPoint origin;

/*! 
 @property radius
 @abstract Radius of this bubble.
 */
@property (nonatomic, assign) CGFloat radius;

/*! 
 @property color
 @abstract Color of this bubble.
 @discussion Alpha is ignored.
 */
@property (nonatomic, strong) UIColor *color;

/*! 
 @property title
 @abstract Title text of this bubble.
 */
@property (nonatomic, strong) NSString *title;

/*! 
 @property numElements
 @abstract Number of contained elements.
 @discussion This is used for the count text display only. So the real number of contained elements can differ if needed.
 */
@property (nonatomic, strong) NSString * numElements;


/*! 
 @property type
 @abstract The type of this bubble.
 @discussion This discerns regular from discovered bubbles.
 */
@property (nonatomic, assign) BubbleType type;


/*! 
 @property isLeaf
 @abstract Whether this bubble is a leaf or if it has children.
 */
@property (nonatomic, assign) BOOL isLeaf;

/*! 
 @property mayHaveCover
 @abstract Indicator that this bubble may have a cover.
 @discussion Still, the bubbleDataSource can return nil for coverForKeyPath: later on.
 */
@property (nonatomic, assign) BOOL mayHaveCover;

@property (nonatomic, strong) UIImage *icon;

/*!
 @method rect
 @abstract A convenience method for calculating the rectangle covered by this bubble.
 @result The rectangle covered by this bubble. 
 */
- (CGRect)rect;

/*!
 @method hasPosition
 @abstract Calculate whether the origin is already set.
 @result Whether the origin is already set. 
 */
- (BOOL)hasPosition;

@end

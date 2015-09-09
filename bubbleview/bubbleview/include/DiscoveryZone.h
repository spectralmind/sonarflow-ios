#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 @class DiscoveryZone
 
 @abstract A DiscoveryZone object represents the selected bubbles in discovery mode.
 */
@interface DiscoveryZone : NSObject

/*! 
 @property members
 @abstract An array with all selected items of the current discovery zone.
 @discussion Contains objects of type DiscoveryZoneMember.
 */
@property (nonatomic, strong) NSArray *members;

/*! 
 @property center
 @abstract The center of the discovery zone in the view.
 */
@property (nonatomic, assign) CGPoint center;

/*! 
 @property radius
 @abstract The radius of the discovery zone, the distance to the bubbles from the center of the discovery center.
 */
@property (nonatomic, assign) CGFloat radius;

@end

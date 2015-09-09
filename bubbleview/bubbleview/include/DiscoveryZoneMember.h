#import <Foundation/Foundation.h>

/*!
 @class DiscoveryZoneMember
 
 @abstract A DiscoveryZoneMember object represents one of the the selected bubbles in discovery mode.
 */
@interface DiscoveryZoneMember : NSObject

/*! 
 @property keyPath
 @abstract The keyPath of this member.
 */
@property (nonatomic, strong) NSArray *keyPath;

/*! 
 @property distanceFromCenter
 @abstract The distance to this member from the center of the discovery center.
 */
@property (nonatomic, assign) float distanceFromCenter;

@end

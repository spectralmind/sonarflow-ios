#import <Foundation/Foundation.h>

@protocol SFMediaLibrary;
@class SFSmartistFactory;
@class DiscoveryZone;

@protocol DiscoveryResultDelegate <NSObject>
- (void)doneWithSimilarityQuery:(NSArray *)similarArtists fromZone:(DiscoveryZone *)zone;
@end

@interface DiscoveryCoordinator : NSObject

- (id)initWithFactory:(SFSmartistFactory *)factory library:(id<SFMediaLibrary>)theLibrary;

@property (nonatomic, strong) NSObject<DiscoveryResultDelegate> *resultDelegate;

- (void)zoneContentChangedTo:(DiscoveryZone *)discoverZone;
- (NSString *)artistNameForDiscoveryFromKeyPath:(NSArray *)keyPath;

@end

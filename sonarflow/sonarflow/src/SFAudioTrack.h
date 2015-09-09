#import <Foundation/Foundation.h>

@protocol SFAudioTrack <NSObject>

- (NSString *)artistName;
- (NSString *)albumName;
- (NSString *)albumArtistName;

- (BOOL)isEquivalentToAudioTrack:(id<SFAudioTrack>)otherTrack;

@end

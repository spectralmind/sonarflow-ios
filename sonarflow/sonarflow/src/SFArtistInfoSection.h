#import <Foundation/Foundation.h>

#import "SFTableViewSection.h"

@protocol SFMediaItem;

@interface SFArtistInfoSection : NSObject <SFTableViewSection>

- (id)initWithMediaItem:(NSObject<SFMediaItem> *)theMediaItem;

@end

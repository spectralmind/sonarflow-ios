#import <Foundation/Foundation.h>

#import "SFMediaItem.h"

@protocol SFITunesMediaItem <SFMediaItem>
@property (nonatomic, readonly) NSArray *tracks;
@property (nonatomic, readonly) BOOL loading;
@end

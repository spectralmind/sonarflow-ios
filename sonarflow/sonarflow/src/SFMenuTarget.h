#import <Foundation/Foundation.h>

@protocol SFMediaItem;

@interface SFMenuTarget : NSObject

+ (SFMenuTarget *)menuTargetWithMediaItem:(NSObject<SFMediaItem> *)theMediaItem boundingRect:(CGRect)theBoundingRect;

@property (nonatomic, readonly) NSObject<SFMediaItem> *mediaItem;
@property (nonatomic, readonly) CGRect boundingRect;

@end

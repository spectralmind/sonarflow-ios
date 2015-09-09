#import <Foundation/Foundation.h>

#import "SFMediaItem.h"

@interface SFAbstractMediaItemComposite : NSObject <SFMediaItem>

@property (nonatomic, assign) BOOL showArtists;
@property (nonatomic, readonly) NSArray *mediaItems;

- (id)initWithName:(NSString *)theName mediaItems:(NSArray *)theMediaItems;

@end

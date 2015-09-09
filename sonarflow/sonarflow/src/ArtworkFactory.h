#import <Foundation/Foundation.h>

@class MPMediaItem;
@class ImageFactory;

@interface ArtworkFactory : NSObject

- (id)initWithImageFactory:(ImageFactory *)theImageFactory;

- (UIImage *)artworkForMediaItem:(MPMediaItem *)item withSize:(CGSize)size;

@end

#import <Foundation/Foundation.h>

@interface ImageFactory : NSObject

@property (weak, nonatomic, readonly) UIImage *nowPlayingImage;
#ifdef SF_SPOTIFY
@property (nonatomic, readonly) UIImage *starIconInactive;
@property (nonatomic, readonly) UIImage *starIcon;
#else
@property (weak, nonatomic, readonly) UIImage *buyOnItunesImage;
#endif

- (UIImage *)defaultCoverForSize:(CGSize)size;

@end

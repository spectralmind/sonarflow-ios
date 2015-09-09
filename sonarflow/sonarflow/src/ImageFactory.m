#import "ImageFactory.h"

@implementation ImageFactory {
	UIImage *defaultCoverImage;
	UIImage *defaultBGCoverImage;
	UIImage *nowPlayingImage;
#ifdef SF_SPOTIFY
	UIImage *starIcon;
	UIImage *starIconInactive;
#else
	UIImage *buyOnItunesImage;
#endif
}


- (UIImage *)nowPlayingImage {
	if(nowPlayingImage == nil) {
		nowPlayingImage = [UIImage imageNamed:@"currentlyplaying.png"];
	}
	
	return nowPlayingImage;
}

#ifdef SF_SPOTIFY
- (UIImage *)starIconInactive {
	if(starIconInactive == nil) {
		starIconInactive = [UIImage imageNamed:@"ratestarOFF"];
	}
	
	return starIconInactive;
}

- (UIImage *)starIcon {
	if(starIcon == nil) {
		starIcon = [UIImage imageNamed:@"ratestarON"];
	}
	
	return starIcon;
}
#else
- (UIImage *)buyOnItunesImage {
	if(buyOnItunesImage == nil) {
		buyOnItunesImage = [UIImage imageNamed:@"iTunes_download.png"];
	}
	
	return buyOnItunesImage;
}
#endif

- (UIImage *)defaultCoverForSize:(CGSize)size {
	if(size.width > 100 || size.height > 100) {
		return [self defaultBGCoverImage];
	}
	else {
		return [self defaultCoverImage];
	}
}

- (UIImage *)defaultCoverImage {
	if(defaultCoverImage == nil) {
		defaultCoverImage = [UIImage imageNamed:@"default_cover.png"];
	}
	
	return defaultCoverImage;
}

- (UIImage *)defaultBGCoverImage {
	if(defaultBGCoverImage == nil) {
		defaultBGCoverImage = [UIImage imageNamed:@"default_bg_cover.png"];
	}
	
	return defaultBGCoverImage;
}

@end

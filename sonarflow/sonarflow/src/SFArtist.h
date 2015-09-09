#import <Foundation/Foundation.h>

#import "CollectionWithChildren.h"
#import "SFDiscoverableItem.h"

@class SFNativeMediaFactory;

@interface SFArtist : CollectionWithChildren <SFDiscoverableItem> {
	BOOL compilationArtist;
}

@property (nonatomic, assign, getter = isCompilationArtist) BOOL compilationArtist;

- (NSArray *)pushTracksIntoAlbumChildrenWithFactory:(SFNativeMediaFactory *)factory;

@end

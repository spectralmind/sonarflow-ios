#import <Foundation/Foundation.h>

@protocol SFMediaItem;

@interface SFMediaItemHelper : NSObject {

}

+ (NSString *)summaryForMediaItem:(id<SFMediaItem>)mediaItem
			   includingAlbum:(BOOL)showAlbum artist:(BOOL)showArtist;

@end

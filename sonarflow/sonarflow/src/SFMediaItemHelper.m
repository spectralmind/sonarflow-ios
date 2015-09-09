#import "SFMediaItemHelper.h"

#import "SFMediaItem.h"
#import "SFAudioTrack.h"

@implementation SFMediaItemHelper

+ (NSString *)summaryForMediaItem:(id<SFMediaItem>)mediaItem
				   includingAlbum:(BOOL)showAlbum artist:(BOOL)showArtist {
	if(!showAlbum && !showArtist) {
		return nil;
	}
	
	NSMutableArray *subtitleComponents = [NSMutableArray arrayWithCapacity:2];
	
	if(showAlbum && [mediaItem conformsToProtocol:@protocol(SFAudioTrack)]) {
		id<SFMediaItem, SFAudioTrack> track = (id<SFMediaItem, SFAudioTrack>)mediaItem;
		NSString *albumName = [track albumName];
		if([albumName length] > 0) {
			[subtitleComponents addObject:albumName];
		}
	}
	if(showArtist && [mediaItem respondsToSelector:@selector(artistName)]) {
		NSString *artistName = [mediaItem artistName];
		if([artistName length] > 0) {
			[subtitleComponents addObject:artistName];
		}
	}
	
	if([subtitleComponents count] == 0) {
		return nil;
	}
	
	return [subtitleComponents componentsJoinedByString:@" - "];	
}


@end

#import "SFGenreFetcherRequestData.h"

@implementation SFGenreFetcherRequestData

+ (SFGenreFetcherRequestData *)genreFetcherRequestDataWithArtistName:(NSString *)artist mediaItems:(NSArray *)mediaItems {
	SFGenreFetcherRequestData *obj = [[self alloc] init];
	obj.artistName = artist;
	obj.mediaItems = mediaItems;
	
	return obj;
}

@end

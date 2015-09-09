#import <Foundation/Foundation.h>

@interface SFGenreFetcherRequestData : NSObject

@property (nonatomic, strong) NSString *artistName;
@property (nonatomic, strong) NSArray *mediaItems;
@property (nonatomic, strong) NSArray *results;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSString *recognizedArtist;

+ (SFGenreFetcherRequestData *)genreFetcherRequestDataWithArtistName:(NSString *)artist mediaItems:(NSArray *)mediaItems;

@end

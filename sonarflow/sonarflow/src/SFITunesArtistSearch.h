#import <Foundation/Foundation.h>

@protocol SFITunesMediaItem;

typedef void (^iTunesArtistResultBlock)(NSArray *topTracks, NSError *error);

@interface SFITunesArtistSearch : NSObject

- (id)initWithArtistName:(NSString *)theArtistName parentForChildren:(id<SFITunesMediaItem>)theParent;

- (void)startWithCompletion:(iTunesArtistResultBlock)theCompletionBlock;

@end

#import <Foundation/Foundation.h>

#import "SFITunesMediaItem.h"
#import "SFAudioTrack.h"

@interface SFITunesAudioTrack : NSObject <SFITunesMediaItem, SFAudioTrack>

- (id)initWithURL:(NSURL *)theUrl name:(NSString *)theName artist:(NSString *)theArtistName album:(NSString *)theAlbumName duration:(NSNumber *)theDuration buyLink:(NSURL *)theBuyLink parent:(id<SFITunesMediaItem>)theParent;

@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSURL *buyLink;
@end

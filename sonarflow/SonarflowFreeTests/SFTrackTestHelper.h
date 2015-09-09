#import <Foundation/Foundation.h>
#import "SFTrack.h"

@interface SFTrackTestHelper : NSObject

+ (SFTrack *)trackWithGenre:(NSString *)genre artist:(NSString *)artist albumArtist:(NSString *)albumArtist album:(NSString *)album compilation:(BOOL)compilation trackNumber:(NSNumber *)trackNumber artworkFactory:(ArtworkFactory *)theArtworkFactory nameGenreMapper:(NameGenreMapper *)theNameGenreMapper player:(SFNativeMediaPlayer *)thePlayer;

+ (SFTrack *)trackWithId:(NSUInteger)trackId genre:(NSString *)genre artist:(NSString *)artist albumArtist:(NSString *)albumArtist album:(NSString *)album compilation:(BOOL)compilation disc:(NSUInteger)disc trackNumber:(NSNumber *)trackNumber artworkFactory:(ArtworkFactory *)theArtworkFactory nameGenreMapper:(NameGenreMapper *)theNameGenreMapper player:(SFNativeMediaPlayer *)thePlayer;

@end

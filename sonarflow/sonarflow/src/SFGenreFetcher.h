#import <Foundation/Foundation.h>

@class AppFactory;

@interface SFGenreFetcher : NSObject

- (void)registerMediaItem:(id)object forLookupWithArtistName:(NSString *)artistName;

- (void)lookupRegisteredMediaItems;

- (BOOL)hasPendingRequests;
- (NSArray *)waitForResults; //< thread safe

@end

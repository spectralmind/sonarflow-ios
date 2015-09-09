#import <Foundation/Foundation.h>

@class SFNativeMediaFactory;
@class GANHelper;
@class SFGenre;

@protocol SFNativeMediaLibraryLoaderDelegate;

@interface SFNativeMediaLibraryLoader : NSObject

- (id)initWithFactory:(SFNativeMediaFactory *)theFactory ganHelper:(GANHelper *)theGanHelper operationQueue:(NSOperationQueue *)theOperationQueue lookupUnknownGenres:(BOOL)lookupEnabled;

@property (nonatomic, weak) NSObject<SFNativeMediaLibraryLoaderDelegate> *delegate;
@property (nonatomic, readonly, getter = isLoading) BOOL loading;
@property (readonly) BOOL lookupEnabled;

- (void)startIfNecessary;
- (void)cancel;

@end

@protocol SFNativeMediaLibraryLoaderDelegate <NSObject>

- (void)willStartLoading;
- (void)loadedGenre:(SFGenre *)genre;
- (void)loadingFailedWithError:(NSError *)error;
- (void)didFinishLoading;

@end

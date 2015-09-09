#import <Foundation/Foundation.h>

#import "SFMediaLibrary.h"

@class GANHelper;
@class ArtworkFactory;
@class PersistentStore;
@class ImageFactory;

@interface SFNativeMediaLibrary : NSObject <SFMediaLibrary> 

- (id)initWithDocumentsDirectory:(NSString *)documentsDirectory ganHelper:(GANHelper *)theGanHelper imageFactory:(ImageFactory *)theImageFactory otherBubbleFixup:(BOOL)unknownGenreLookupEnabled;

@end
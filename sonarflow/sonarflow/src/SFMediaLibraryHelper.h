#import <Foundation/Foundation.h>

@protocol SFMediaItem;

@interface SFMediaLibraryHelper : NSObject

+ (NSObject<SFMediaItem> *)mediaItemForKeyPath:(NSArray *)keyPath inArray:(NSArray *)items;

+ (id<SFMediaItem>)mediaItemForKey:(id)key inArray:(NSArray *)items;

@end

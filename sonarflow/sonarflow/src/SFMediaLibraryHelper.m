#import "SFMediaLibraryHelper.h"

#import "SFMediaItem.h"

@implementation SFMediaLibraryHelper


+ (NSObject<SFMediaItem> *)mediaItemForKeyPath:(NSArray *)keyPath inArray:(NSArray *)items {
	if([keyPath count] == 0) {
		return nil;
	}
	
	NSObject<SFMediaItem> *result = [self mediaItemForKey:[keyPath objectAtIndex:0] inArray:items];
	for(NSUInteger i = 1; i < [keyPath count]; ++i) {
		result = [result childWithKey:[keyPath objectAtIndex:i]];
	}
	
	return result;
}

+ (id<SFMediaItem>)mediaItemForKey:(id)key inArray:(NSArray *)items {
	for(id<SFMediaItem> item in items) {
		if([item.key isEqual:key]) {
			return item;
		}
	}
	
	return nil;
}

@end

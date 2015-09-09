#import <Foundation/Foundation.h>

#import "SFTableViewSection.h"

@protocol SFMediaItem;

@interface SFAllChildrenRowSection : NSObject <SFTableViewSection>

- (id)initWithMediaItem:(NSObject<SFMediaItem> *)theMediaItem allElementsTitle:(NSString *)theAllElementsTitle;

@end

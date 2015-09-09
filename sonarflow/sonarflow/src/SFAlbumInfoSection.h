#import <Foundation/Foundation.h>

#import "SFTableViewSection.h"

@protocol SFMediaItem;

@interface SFAlbumInfoSection : NSObject <SFTableViewSection>

- (id)initWithMediaItem:(NSObject<SFMediaItem> *)theMediaItem;

@property (nonatomic, strong) IBOutlet UITableViewCell *albumHeaderCell;

@end

#import <Foundation/Foundation.h>

#import "SFTableViewSection.h"

@protocol SFMediaItem;

@interface SFAbstractMediaItemSection : NSObject <SFTableViewSection>

- (id)initWithMediaItem:(NSObject<SFMediaItem> *)theMediaItem;

@property (nonatomic, assign) BOOL showAlbumName;
@property (nonatomic, assign) BOOL showArtistName;
@property (nonatomic, readonly) NSObject<SFMediaItem> *mediaItem;

//Pure vitual:
- (UITableViewCell *)cellForChildItem:(id<SFMediaItem>)childItem atRow:(NSUInteger)row inTableView:(UITableView *)tableView;
@end

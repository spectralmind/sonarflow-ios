#import <Foundation/Foundation.h>

@protocol SFMediaItem;
@protocol SFRootItem;
@class ImageFactory;
@class Bubble;
@class SMSimilarArtist;
@class RootKey;

@interface BubbleFactory : NSObject

@property (nonatomic, assign) CGFloat maxBubbleRadius;
@property (nonatomic, assign) CGFloat toplayerMinBubbleRadius;
@property (nonatomic, assign) CGFloat childrenRadiusFactor;
@property (nonatomic, assign) NSInteger maxTextLength;
@property (nonatomic, assign) CGSize coverSize;

- (id)initWithImageFactory:(ImageFactory *)theImageFactory;

- (NSArray *)bubblesForRootMediaItems:(NSArray *)mediaItems;
- (NSArray *)bubblesForChildren:(NSArray *)children ofBubble:(Bubble *)bubble avoidingBubbles:(NSArray *)bubblesToAvoid;

- (void)updateBubble:(Bubble *)bubble withParent:(Bubble *)parentBubble fromMediaItem:(id<SFMediaItem>)mediaItem;

- (Bubble *)bubbleForDiscoveredArtist:(SMSimilarArtist *)artist withRadius:(CGFloat)radius;
- (RootKey *)rootKeyForDiscoveredArtist:(SMSimilarArtist *)artist;


@end

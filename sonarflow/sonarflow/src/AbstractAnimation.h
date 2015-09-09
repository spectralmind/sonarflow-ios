#import <Foundation/Foundation.h>

@protocol AnimationDelegate;

@interface AbstractAnimation : NSObject

@property (nonatomic,weak) id<AnimationDelegate> delegate;

- (id)initWithDuration:(NSTimeInterval)theDuration;

- (void)start;
- (void)stop;

//Pure virtual methods
- (void)updateToProgress:(CGFloat)progress;

@end

@protocol AnimationDelegate

- (CGPoint)bubbleSpaceLocationForViewLocation:(CGPoint)location;
- (void)animation:(AbstractAnimation *)theAnimation setScale:(CGFloat)scale centeredOnViewLocation:(CGPoint)location;
- (void)animation:(AbstractAnimation *)theAnimation setTranslation:(CGPoint)translation;
- (void)animation:(AbstractAnimation *)theAnimation translateByBubbleCoordinates:(CGPoint)translation;
- (void)animationFinished:(AbstractAnimation *)theAnimation;

@end
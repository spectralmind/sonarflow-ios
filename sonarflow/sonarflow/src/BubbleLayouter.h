//
//  BubbleLayouter.h
//  sonarflow
//
//  Created by Raphael Charwot on 27.08.11.
//  Copyright (c) 2011 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Bubble;

@interface BubbleLayouter : NSObject

@property (nonatomic, readonly, strong) NSArray *failedBubbles;
@property (nonatomic, readonly, strong) NSArray *succeededBubbles;

- (NSArray *)sortAndLayoutBubbles:(NSArray *)bubbles inRadius:(CGFloat)radius avoidingBubbles:(NSArray *)theBubblesToAvoid;

- (CGPoint)randomPositionWithRadius:(CGFloat)childRadius inRadius:(CGFloat)radius;
- (void)collision:(int)attempts;
- (NSArray *)sortBubblesByRadius:(NSArray *)bubbles;

@end
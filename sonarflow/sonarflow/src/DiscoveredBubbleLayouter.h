//
//  DiscoveredBubbleLayouter.h
//  sonarflow
//
//  Created by Arvid Staub on 27.04.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "BubbleLayouter.h"

@interface DiscoveredBubbleLayouter : BubbleLayouter

- (id)initWithCenterLocation:(CGPoint)centerLocation withBounds:(CGRect)bound withNumberOfBubbles:(int)bubbles;
@end

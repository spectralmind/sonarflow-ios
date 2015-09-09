//
//  CTView.h
//  CoreTextMagazine
//
//  Created by Marin Todorov on 8/11/11.
//  Copyright 2011 Marin Todorov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTColumnView.h"

@interface CTView : UIScrollView

@property (assign, nonatomic) UIEdgeInsets inset;
@property (assign, nonatomic) CGFloat frameWidth;
@property (assign, nonatomic) CGFloat frameSpacing;

- (void)setAttString:(NSAttributedString *)attString withImages:(NSArray*)imgs;

@end

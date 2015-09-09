//
//  UIScrollView+PageScrollView.h
//  sonarflow
//
//  Created by Raphael Charwot on 19.03.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIScrollView (PageScrollView)

- (void)scrollToPage:(int)page animated:(BOOL)animated;

@end

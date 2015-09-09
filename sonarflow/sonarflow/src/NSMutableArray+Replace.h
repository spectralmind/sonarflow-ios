//
//  NSMutableArray+Replace.h
//  Sonarflow
//
//  Created by Raphael Charwot on 06.02.11.
//  Copyright 2011 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSMutableArray (Replace)

- (void)replace:(NSObject *)original with:(NSObject *)replacement;

@end

//
//  Formatter.h
//  Sonarflow
//
//  Created by Raphael Charwot on 05.11.10.
//  Copyright 2010 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Formatter : NSObject {
}

+ (NSString *)formatDuration:(NSTimeInterval)duration;

@end

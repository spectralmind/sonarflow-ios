//
//  SMArtistWebInfoTimeMeasurement.h
//  SMArtist
//
//  Created by Fabian on 29.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMArtistWebInfoTimeMeasurement : NSObject

@property (nonatomic, strong) NSArray *timesTaken;

- (void)startTimeMeasurement;

- (void)setTimeMeasurePointForNow:(NSString *)description;

- (void)endTimeMeasurement;

@end

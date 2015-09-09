//
//  SMArtistWebInfoTimeMeasurement.m
//  SMArtist
//
//  Created by Fabian on 29.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//

#import "SMArtistWebInfoTimeMeasurement.h"

@implementation SMArtistWebInfoTimeMeasurement
{
@private
    NSMutableArray *_timeTaken;
    NSDate *_lastMeasured;    
}

@synthesize timesTaken=_timeTaken; // maps mutable array to nonmutable


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


#pragma mark - Public Methods

- (void)startTimeMeasurement
{
    [self endTimeMeasurement];
    _timeTaken = [[NSMutableArray alloc] init];
    _lastMeasured = [NSDate date];
}

- (void)setTimeMeasurePointForNow:(NSString *)description
{
    // TODO save description string
    //NSLog(@"Time Taken at: %@",description);
    [_timeTaken addObject:[NSNumber numberWithFloat:-[_lastMeasured timeIntervalSinceNow]]];
}

- (void)endTimeMeasurement
{
    if (_timeTaken) {
        _timeTaken = nil;
    }
    if (_lastMeasured) {
        _lastMeasured = nil;
    }
}

@end

//
//  SMArtistWebInfo+ReturnHelper.h
//  SMArtist
//
//  Created by Fabian on 01.09.11.
//  Copyright (c) 2011 Spectralmind. All rights reserved.
//

#import "SMArtistWebInfo.h"

@interface SMArtistWebInfo (Private)


#pragma mark - Private Helper Methods

- (SMArtistResult *)emptyResult;

- (void)setAvailable;

- (void)sendOutErrorResultWithError:(NSError *)error;

- (void)sendOutErrorResultWithErrorString:(NSString *)errorString;

- (void)sendOutResult:(SMArtistResult *)result;

- (void)setResultDetails:(SMArtistResult *)result;

@end

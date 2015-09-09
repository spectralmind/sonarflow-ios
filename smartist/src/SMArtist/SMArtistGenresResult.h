//
//  SMArtistGenresResult.h
//  SMArtist
//
//  Created by Arvid Staub on 9.8.2012.
//
//

#import "SMArtistResult.h"

@interface SMArtistGenresResult : SMArtistResult

+ (SMArtistGenresResult *)result;
- (id)initWithResults:(NSArray *)results;

@property (nonatomic, readwrite) NSArray *genres;
@end

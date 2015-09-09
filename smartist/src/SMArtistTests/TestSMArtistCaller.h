#import <Foundation/Foundation.h>

#import "SMArtist.h"
#import "CannedResultAbstract.h"


@interface TestSMArtistCallerParams : NSObject
@property (strong) id clientId;
@property (assign) BOOL priority;
@property (strong) NSString *artistName;
@property (strong) NSArray *artistNames;
+ (TestSMArtistCallerParams *)testSMArtistCallerParamsWithPriority:(BOOL)priority clientId:(id)clientId artistName:(NSString *)artistName artistNames:(NSArray *)artistNames;
@end

@interface TestSMArtistCaller : NSObject
- (void)callSMArtist:(SMArtist *)smartist withParams:(TestSMArtistCallerParams *)params;
- (id)getSMArtistResponseDelegateMockForCannedResult:(CannedResultAbstract *)cannedResult;
@end

@interface TestSMArtistCallerBios : TestSMArtistCaller
@end

@interface TestSMArtistCallerSimilarity : TestSMArtistCaller
@end

@interface TestSMArtistCallerSimilarityMatrix : TestSMArtistCaller
@end

@interface TestSMArtistCallerImages : TestSMArtistCaller
@end

@interface TestSMArtistCallerVideos : TestSMArtistCaller
@end

@interface TestSMArtistCallerGenres : TestSMArtistCaller
@end


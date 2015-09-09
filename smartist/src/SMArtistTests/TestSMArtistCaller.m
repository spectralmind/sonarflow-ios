#import "TestSMArtistCaller.h"

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMock/OCMock.h>

// also allows SMArtist calling performSelectorOnMainThread:withObject:waitUntilDone:
@interface TestSMArtistDelegate : NSObject <SMArtistDelegate>

@end

// all optional protocol methods must be stubbed here
@implementation TestSMArtistDelegate

- (void)doneWebRequestWithArtistBiosResult:(SMArtistBiosResult *)theResult {}
- (void)doneWebRequestWithArtistSimilarityResult:(SMArtistSimilarityResult *)theResult {}
- (void)doneWebRequestWithArtistSimilarityMatrixResult:(SMArtistSimilarityMatrixResult *)theResult {}
- (void)doneWebRequestWithArtistImagesResult:(SMArtistImagesResult *)theResult {}
- (void)doneWebRequestWithArtistVideosResult:(SMArtistVideosResult *)theResult {}
- (void)doneWebRequestWithArtistGenresResult:(SMArtistGenresResult *)theResult {}

@end



@implementation TestSMArtistCallerParams
@synthesize priority;
@synthesize clientId;
@synthesize artistName;
@synthesize artistNames;

+ (TestSMArtistCallerParams *)testSMArtistCallerParamsWithPriority:(BOOL)priority clientId:(id)clientId artistName:(NSString *)artistName artistNames:(NSArray *)artistNames {
	TestSMArtistCallerParams *params = [[TestSMArtistCallerParams alloc] init];
	params.priority = priority;
	params.clientId = clientId;
	params.artistName = artistName;
	params.artistNames = artistNames;
	return params;
}

@end


@implementation TestSMArtistCaller
- (void)callSMArtist:(SMArtist *)smartist withParams:(TestSMArtistCallerParams *)params {
	[self doesNotRecognizeSelector:_cmd];
}
- (id)getSMArtistResponseDelegateMockForCannedResult:(CannedResultAbstract *)cannedResult {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}
@end

@implementation TestSMArtistCallerBios
- (void)callSMArtist:(SMArtist *)smartist withParams:(TestSMArtistCallerParams *)params {
	[smartist getArtistBiosWithArtistName:params.artistName clientId:params.clientId priority:params.priority];
}
- (id)getSMArtistResponseDelegateMockForCannedResult:(CannedResultAbstract *)cannedResult {
	id smartistdelegatemock = [OCMockObject partialMockForObject:[[TestSMArtistDelegate alloc] init]];
    [[smartistdelegatemock expect] doneWebRequestWithArtistBiosResult:[OCMArg checkWithSelector:@selector(checkOk:) onObject:cannedResult]];
    return smartistdelegatemock;
}
@end

@implementation TestSMArtistCallerSimilarity
- (void)callSMArtist:(SMArtist *)smartist withParams:(TestSMArtistCallerParams *)params {
	[smartist getArtistSimilarityWithArtistName:params.artistName clientId:params.clientId priority:params.priority];
}
- (id)getSMArtistResponseDelegateMockForCannedResult:(CannedResultAbstract *)cannedResult {
	id smartistdelegatemock = [OCMockObject partialMockForObject:[[TestSMArtistDelegate alloc] init]];
    [[smartistdelegatemock expect] doneWebRequestWithArtistSimilarityResult:[OCMArg checkWithSelector:@selector(checkOk:) onObject:cannedResult]];
    return smartistdelegatemock;
}
@end

@implementation TestSMArtistCallerSimilarityMatrix
- (void)callSMArtist:(SMArtist *)smartist withParams:(TestSMArtistCallerParams *)params {
	[smartist getArtistSimilarityMatrixWithArtistNames:params.artistNames clientId:params.clientId priority:params.priority];
}
- (id)getSMArtistResponseDelegateMockForCannedResult:(CannedResultAbstract *)cannedResult {
	id smartistdelegatemock = [OCMockObject partialMockForObject:[[TestSMArtistDelegate alloc] init]];
    [[smartistdelegatemock expect] doneWebRequestWithArtistSimilarityMatrixResult:[OCMArg checkWithSelector:@selector(checkOk:) onObject:cannedResult]];
    return smartistdelegatemock;
}
@end

@implementation TestSMArtistCallerImages
- (void)callSMArtist:(SMArtist *)smartist withParams:(TestSMArtistCallerParams *)params {
	[smartist getArtistImagesWithArtistName:params.artistName clientId:params.clientId priority:params.priority];
}
- (id)getSMArtistResponseDelegateMockForCannedResult:(CannedResultAbstract *)cannedResult {
	id smartistdelegatemock = [OCMockObject partialMockForObject:[[TestSMArtistDelegate alloc] init]];
    [[smartistdelegatemock expect] doneWebRequestWithArtistImagesResult:[OCMArg checkWithSelector:@selector(checkOk:) onObject:cannedResult]];
    return smartistdelegatemock;
}
@end

@implementation TestSMArtistCallerVideos
- (void)callSMArtist:(SMArtist *)smartist withParams:(TestSMArtistCallerParams *)params {
	[smartist getArtistVideosWithArtistName:params.artistName clientId:params.clientId priority:params.priority];
}
- (id)getSMArtistResponseDelegateMockForCannedResult:(CannedResultAbstract *)cannedResult {
	id smartistdelegatemock = [OCMockObject partialMockForObject:[[TestSMArtistDelegate alloc] init]];
    [[smartistdelegatemock expect] doneWebRequestWithArtistVideosResult:[OCMArg checkWithSelector:@selector(checkOk:) onObject:cannedResult]];
    return smartistdelegatemock;
}
@end

@implementation TestSMArtistCallerGenres
- (void)callSMArtist:(SMArtist *)smartist withParams:(TestSMArtistCallerParams *)params {
	[smartist getArtistGenresWithArtistName:params.artistName clientId:params.clientId priority:params.priority];
}
- (id)getSMArtistResponseDelegateMockForCannedResult:(CannedResultAbstract *)cannedResult {
	id smartistdelegatemock = [OCMockObject partialMockForObject:[[TestSMArtistDelegate alloc] init]];
    [[smartistdelegatemock expect] doneWebRequestWithArtistGenresResult:[OCMArg checkWithSelector:@selector(checkOk:) onObject:cannedResult]];
    return smartistdelegatemock;
}
@end

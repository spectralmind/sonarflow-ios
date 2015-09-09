// INFO: OCMock.framework only works with logic tests in simulator, for application tests on device, static lib is needed
//       Here, the static lib is used as it works for both

// still to do:
//   Correct Request => Error Answer
//   Unavailable Request => "Unavailable" Result
//   Faulty Request => Error Answer


#import "SMArtistTests.h"

#import "CannedResultSingle.h"
#import "CannedResultMulti.h"
#import "TestSMArtistCaller.h"

#import "SMArtist.h"
#import "SMRootFactory.h"
#import "SMArtistWebInfo.h"

#import "SMArtistResult.h"
#import "SMArtistBiosResult.h"
#import "SMArtistBio.h"
#import "SMArtistSimilarityResult.h"
#import "SMSimilarArtist.h"
#import "SMArtistImagesResult.h"
#import "SMArtistImage.h"
#import "SMRateLimitedQueue.h"

#define kEchonestKey @"YV4GJANNDGN3MWBQG"
#define kLastfmKey @"fce4ee314339e5192fe28938e4795b9b"


// for accessing private property
@interface SMArtist (Test)
@property (nonatomic, retain) SMRootFactory *rootFactory;
@end


@implementation SMArtistTests


#pragma mark - Setup and helper methods

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


#pragma mark Requests

- (SMRootFactory *)rootFactoryServingOnlyFromWebservice:(SMArtistWebServices)service {
	SMArtistConfiguration *config = [SMArtistConfiguration defaultConfiguration];
	config.servicesMaskAllRequests = service;
	return [[SMRootFactory alloc] initWithConfiguration:config];
}

- (SMSingleArtistRequest *)requestSimilarityForArtistName:(NSString *)artistName fromWebservice:(SMArtistWebServices)service withClientId:(id)clientId
{
	SMArtistRequest *request = [[self rootFactoryServingOnlyFromWebservice:service].requestFactory artistSimilarityRequestWithClientId:nil withArtistName:artistName priority:NO];
	request.clientId = clientId;
	NSAssert([request isKindOfClass:[SMSingleArtistRequest class]], @"Unexpected request class");
	return (SMSingleArtistRequest *)request;
}

- (SMSingleArtistRequest *)requestImagesForArtistName:(NSString *)artistName fromWebservice:(SMArtistWebServices)service withClientId:(id)clientId
{
	SMArtistRequest *request = [[self rootFactoryServingOnlyFromWebservice:service].requestFactory artistImagesRequestWithClientId:nil withArtistName:artistName priority:NO];
	request.clientId = clientId;
	NSAssert([request isKindOfClass:[SMSingleArtistRequest class]], @"Unexpected request class");
	return (SMSingleArtistRequest *)request;
}

- (SMSingleArtistRequest *)requestBiosForArtistName:(NSString *)artistName fromWebservice:(SMArtistWebServices)service withClientId:(id)clientId
{
	SMArtistRequest *request = [[self rootFactoryServingOnlyFromWebservice:service].requestFactory artistBiosRequestWithClientId:nil withArtistName:artistName priority:NO];
	request.clientId = clientId;
	NSAssert([request isKindOfClass:[SMSingleArtistRequest class]], @"Unexpected request class");
	return (SMSingleArtistRequest *)request;
}


#pragma mark WebInfo Response Mocks

- (id)getWebInfoResponseDelegateMockForCannedResult:(CannedResultSingle *)cannedResult
{
    id webinfodelegatemock = [OCMockObject mockForProtocol:@protocol(SMRequestableDelegate)];
    
    [[webinfodelegatemock expect] doneSMRequestWithRequestable:[OCMArg any] withResult:[OCMArg checkWithSelector:@selector(checkOk:) onObject:cannedResult]];
    
    return webinfodelegatemock;
}

#pragma mark WebInfo Test Methods

- (void)doTestInternalWebInfoWithCannedResult:(CannedResultSingle *)cannedResult {
	SMRootFactory *rootFactoryMock = [self createSemifakeRootFactoryUsingWebservice:cannedResult.request.servicesMask];
	
	id resultDelegate = [self getWebInfoResponseDelegateMockForCannedResult:cannedResult];
	
	SMArtistWebInfo *webinfo = [SMArtistWebInfo webinfoWithConfiguration:rootFactoryMock withDelegate:resultDelegate ForWebservice:rootFactoryMock.configuration.servicesMaskAllRequests forRequestType:cannedResult.request.type];

    id mockConnectionFactory = [OCMockObject mockForClass:[SMUrlConnectionFactory class]];
    [[[mockConnectionFactory stub] andCall:@selector(returnCannedResultForRequest:forDelegate:) onObject:cannedResult]
     newUrlConnectionWithRequest:[OCMArg any] withDelegate:[OCMArg any]];
	
	SMArtistConfiguration *config = [SMArtistConfiguration defaultConfiguration];
    
	SMRootFactory *rootFactory = [[SMRootFactory alloc] initWithConfiguration:config];
    id mockConfigurationFactory = [OCMockObject partialMockForObject:rootFactory];
    [[[mockConfigurationFactory stub] andReturn:mockConnectionFactory] urlconnectionFactory];

    webinfo.rootFactory = mockConfigurationFactory;
	webinfo.request = cannedResult.request;
    
    // actual call to lib
    [webinfo startRequest];
	
	// we need to wait for the result
    NSDate *waittime = [NSDate dateWithTimeIntervalSinceNow:.4];
    [[NSRunLoop currentRunLoop] runUntilDate:waittime];
	
    [(OCMockObject*)resultDelegate verify];
}

- (SMRootFactory *)createSemifakeRootFactoryUsingWebservice:(SMArtistWebServices)service
{
    SMArtistConfiguration *config = [SMArtistConfiguration defaultConfiguration];
	config.servicesMaskAllRequests = service;
	SMRootFactory *rootFactory = [[SMRootFactory alloc] initWithConfiguration:config];
    
	id queueMock = [OCMockObject mockForClass:[SMRateLimitedQueue class]];
	id rootFactoryMock = [OCMockObject partialMockForObject:rootFactory];
	[[[queueMock stub] andCall:@selector(performMockedEnqueueWithPriority:block:) onObject:self] enqueueWithPriority:YES block:[OCMArg any]];	[[[queueMock stub] andCall:@selector(performMockedEnqueueWithPriority:block:) onObject:self] enqueueWithPriority:NO block:[OCMArg any]]; // OCMock workaround
	
	[[[rootFactoryMock stub] andReturn:queueMock] getQueueForEchonest];
	[[[rootFactoryMock stub] andReturn:queueMock] getQueueForLastfm];
	[[[rootFactoryMock stub] andReturn:queueMock] getQueueForYoutube];
    return rootFactoryMock;
}

- (void)performMockedEnqueueWithPriority:(BOOL)priority block:(SMQueueBlock)theWorkBlock {
	NSLog(@"performing mock block.\n");
	theWorkBlock();
}

#pragma mark - Test Case Framework Sanity Checks

- (void)testUsingAssertThat
{
    assertThat(@"xx", is(@"xx"));
    assertThat(@"yy", isNot(@"xx"));
    assertThat(@"i like cheese", containsString(@"cheese"));
    assertThat(nil, equalTo(nil));
    assertThat(nil, isNot(nil));
}

- (void)testUsingNumbers
{
    assertThatInt(42, is(equalToInt(42)));
    assertThatUnsignedShort(6 * 9, isNot(equalToUnsignedShort(42)));
}


#pragma mark - General Test Cases

- (void)testSmartistCreation
{
    SMArtist __unused *smartist = [[SMArtist alloc] initWithAWIDelegate:nil withConfiguration:nil];
}


#pragma mark - Internal Tests

- (void)testInternalWebInfoLastfmSimilarity1
{
	[self doTestInternalWebInfoWithCannedResult: [CannedResultSingle
														successfulCannedResultSingleWithRequest:[self requestSimilarityForArtistName:@"cher" fromWebservice:SMArtistWebServicesLastfm withClientId:nil]
													   canFilename:@"cannedresults/lastfm_similarity_artist-cher_limit-30_correctresponse"]];
}

- (void)testInternalWebInfoEchonestSimilarity1
{
	[self doTestInternalWebInfoWithCannedResult:[CannedResultSingle
													   successfulCannedResultSingleWithRequest:[self requestSimilarityForArtistName:@"cher" fromWebservice:SMArtistWebServicesEchonest withClientId:nil]
													   canFilename:@"cannedresults/echonest_similarity_artist-cher_limit-30_correctresponsee"]];
}

- (void)testInternalWebInfoLastfmImages1
{
	[self doTestInternalWebInfoWithCannedResult:[CannedResultSingle
													   successfulCannedResultSingleWithRequest:[self requestImagesForArtistName:@"cher" fromWebservice:SMArtistWebServicesLastfm withClientId:nil]
													   canFilename:@"cannedresults/lastfm_images_artist-cher_limit-30_correctresponse"]];
}

- (void)testInternalWebInfoEchonestImages1
{
	[self doTestInternalWebInfoWithCannedResult:[CannedResultSingle
													   successfulCannedResultSingleWithRequest:[self requestImagesForArtistName:@"cher" fromWebservice:SMArtistWebServicesEchonest withClientId:nil]
													   canFilename:@"cannedresults/echonest_images_artist-cher_limit-30_correctresponse"]];
}

- (void)testInternalWebInfoLastfmBios1
{
	[self doTestInternalWebInfoWithCannedResult:[CannedResultSingle
													   successfulCannedResultSingleWithRequest:[self requestBiosForArtistName:@"cher" fromWebservice:SMArtistWebServicesLastfm withClientId:nil]
													   canFilename:@"cannedresults/lastfm_bios_artist-cher_limit-30_correctresponse"]];
}

- (void)testInternalWebInfoEchonestBios1
{
	[self doTestInternalWebInfoWithCannedResult:[CannedResultSingle
													   successfulCannedResultSingleWithRequest:[self requestBiosForArtistName:@"cher" fromWebservice:SMArtistWebServicesEchonest withClientId:nil]
													   canFilename:@"cannedresults/echonest_bios_artist-cher_limit-30_correctresponse"]];
}


#pragma mark - Client-Side End-To-End Canned Tests

#pragma mark Correct Request => Correct Answer

- (void)mockUrlConnectionsForSmartist:(SMArtist *)smartist
               withCannedResults:(CannedResultMulti *)cannedResults
{
    id mockConnectionFactory = [OCMockObject mockForClass:[SMUrlConnectionFactory class]];
    [[[mockConnectionFactory stub] andCall:@selector(returnCannedResultForRequest:forDelegate:) onObject:cannedResults]
     newUrlConnectionWithRequest:[OCMArg any] withDelegate:[OCMArg any]];
    
    id rootFactoryMock = [OCMockObject partialMockForObject:smartist.rootFactory];
    [[[rootFactoryMock stub] andReturn:mockConnectionFactory] urlconnectionFactory];
	
	id queueMock = [OCMockObject mockForClass:[SMRateLimitedQueue class]];
	[[[queueMock stub] andCall:@selector(performMockedEnqueueWithPriority:block:) onObject:self] enqueueWithPriority:YES block:[OCMArg any]];
	[[[queueMock stub] andCall:@selector(performMockedEnqueueWithPriority:block:) onObject:self] enqueueWithPriority:NO block:[OCMArg any]]; // OCMock workaround
	
	[[[rootFactoryMock stub] andReturn:queueMock] getQueueForEchonest];
	[[[rootFactoryMock stub] andReturn:queueMock] getQueueForLastfm];
	[[[rootFactoryMock stub] andReturn:queueMock] getQueueForYoutube];
}

- (void)doTestAPIWithCannedResults:(CannedResultMulti *)cannedResults testSMArtistCaller:(TestSMArtistCaller *)testSMArtistCaller testSMArtistCallerParams:(TestSMArtistCallerParams *)testSMArtistCallerParams {
	id resultDelegate = [testSMArtistCaller getSMArtistResponseDelegateMockForCannedResult:cannedResults];
	
	SMArtistConfiguration *config = [SMArtistConfiguration defaultConfiguration];
	config.echonestKey = kEchonestKey;
	config.lastfmKey = kLastfmKey;
    SMArtist *smart = [SMArtist smartistWithDelegate:resultDelegate withConfiguration:config];
    [self mockUrlConnectionsForSmartist:smart withCannedResults:cannedResults];
    
    // actual call to lib
	[testSMArtistCaller callSMArtist:smart withParams:testSMArtistCallerParams];
	
	// we need to wait for the result
    NSDate *waittime = [NSDate dateWithTimeIntervalSinceNow:.4];
    [[NSRunLoop currentRunLoop] runUntilDate:waittime];
    
    [(OCMockObject*)resultDelegate verify];
}


- (void)testCannedAPISimilarity1
{
	id clientId = @"me";
	NSString *artistName = @"cher";
	[self doTestAPIWithCannedResults:[CannedResultMulti cannedResultMultiWithCannedResults:
									  @[
									  [CannedResultSingle successfulCannedResultSingleWithRequest:[self requestSimilarityForArtistName:artistName fromWebservice:SMArtistWebServicesLastfm withClientId:clientId] canFilename:@"cannedresults/lastfm_similarity_artist-cher_limit-30_correctresponse"],
									  [CannedResultSingle
									   successfulCannedResultSingleWithRequest:[self requestSimilarityForArtistName:artistName fromWebservice:SMArtistWebServicesEchonest withClientId:clientId]
									   canFilename:@"cannedresults/echonest_similarity_artist-cher_limit-30_correctresponse"]
									  ]
									  ]
				  testSMArtistCaller:[[TestSMArtistCallerSimilarity alloc] init]
			testSMArtistCallerParams:[TestSMArtistCallerParams testSMArtistCallerParamsWithPriority:NO clientId:clientId artistName:artistName artistNames:nil]
	 ];
}

- (void)testCannedAPIImages1
{
	id clientId = @"me";
	NSString *artistName = @"cher";
	[self doTestAPIWithCannedResults:[CannedResultMulti cannedResultMultiWithCannedResults:
									  @[
									  [CannedResultSingle successfulCannedResultSingleWithRequest:[self requestImagesForArtistName:artistName fromWebservice:SMArtistWebServicesLastfm withClientId:clientId] canFilename:@"cannedresults/lastfm_images_artist-cher_limit-30_correctresponse"],
									  [CannedResultSingle
									   successfulCannedResultSingleWithRequest:[self requestImagesForArtistName:artistName fromWebservice:SMArtistWebServicesEchonest withClientId:clientId]
									   canFilename:@"cannedresults/echonest_images_artist-cher_limit-30_correctresponse"]
									  ]
									  ]
				  testSMArtistCaller:[[TestSMArtistCallerImages alloc] init]
			testSMArtistCallerParams:[TestSMArtistCallerParams testSMArtistCallerParamsWithPriority:NO clientId:clientId artistName:artistName artistNames:nil]
	 ];
}

- (void)testCannedAPIBios1
{
	id clientId = @"me";
	NSString *artistName = @"cher";
	[self doTestAPIWithCannedResults:[CannedResultMulti cannedResultMultiWithCannedResults:
									  @[
									  [CannedResultSingle successfulCannedResultSingleWithRequest:[self requestBiosForArtistName:artistName fromWebservice:SMArtistWebServicesLastfm withClientId:clientId] canFilename:@"cannedresults/lastfm_bios_artist-cher_limit-30_correctresponse"],
									  [CannedResultSingle
									   successfulCannedResultSingleWithRequest:[self requestBiosForArtistName:artistName fromWebservice:SMArtistWebServicesEchonest withClientId:clientId]
									   canFilename:@"cannedresults/echonest_bios_artist-cher_limit-30_correctresponse"]
									  ]
									  ]
				  testSMArtistCaller:[[TestSMArtistCallerBios alloc] init]
			testSMArtistCallerParams:[TestSMArtistCallerParams testSMArtistCallerParamsWithPriority:NO clientId:clientId artistName:artistName artistNames:nil]
	 ];
}

@end

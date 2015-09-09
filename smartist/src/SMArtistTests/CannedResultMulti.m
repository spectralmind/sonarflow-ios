#import "CannedResultMulti.h"

@implementation CannedResultMulti

@synthesize cannedResults;

+ (CannedResultMulti *)cannedResultMultiWithCannedResults:(NSArray *)theCannedResults {
	return [[CannedResultMulti alloc] initCannedResultMultiWithCannedResults:theCannedResults];
}

- (id)initCannedResultMultiWithCannedResults:(NSArray *)theCannedResults {
	self = [super init];
	if (self) {
		cannedResults = theCannedResults;
	}
	return self;
}

- (void)returnCannedResultForRequest:(NSURLRequest *)urlRequest forDelegate:(id<NSURLConnectionDelegate, NSURLConnectionDataDelegate>)delegate {
    assertThat(urlRequest, notNilValue());
    assertThat(delegate, notNilValue());
	
	for (CannedResultSingle *cannedResult in cannedResults) {
		if ([cannedResult responsibleForRequest:urlRequest]) {
			[cannedResult returnCannedResultForRequest:urlRequest forDelegate:delegate];
			return;
		}
	}
    
	STFail(@"No matching CannedResultSingle found");
}

- (BOOL)checkOk:(SMArtistResult *)result {
	STFail(@"TODO would be needed to check merged subresult");
	return NO;
}

@end


#import "CannedResultAbstract.h"

@implementation CannedResultAbstract

- (void)returnCannedResultForRequest:(NSURLRequest *)urlRequest forDelegate:(id<NSURLConnectionDelegate, NSURLConnectionDataDelegate>)delegate {
	[self doesNotRecognizeSelector:_cmd];
}

- (BOOL)checkOk:(SMArtistResult *)result {
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

@end

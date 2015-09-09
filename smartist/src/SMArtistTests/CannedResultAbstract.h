#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMock/OCMock.h>

#import "SMArtistResult.h"


@interface CannedResultAbstract : SenTestCase

- (void)returnCannedResultForRequest:(NSURLRequest *)request forDelegate:(id<NSURLConnectionDelegate, NSURLConnectionDataDelegate>)delegate;

- (BOOL)checkOk:(SMArtistResult *)result;

@end

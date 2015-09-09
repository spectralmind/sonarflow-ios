#import "SFAffiliateLinkGenerator.h"

#import "Configuration.h"

@implementation NSURL (Additions)

- (NSURL *)URLByAppendingQueryString:(NSString *)queryString {
    if([queryString length] == 0) {
        return self;
    }
	
    NSString *URLString = [[NSString alloc] initWithFormat:@"%@%@%@", [self absoluteString],
                           [self query] ? @"&" : @"?", queryString];
    NSURL *theURL = [NSURL URLWithString:URLString];
    return theURL;
}

@end


@implementation SFAffiliateLinkGenerator

static NSString *tradeDoublerPrefix = @"http://clk.tradedoubler.com/click?p=%@&a=%@&url=";
static const NSString *partnerId = @"partnerId=2003";
static NSString *affiliateToken  = @"";

+ (NSURL *)affiliateLink:(NSURL *)url {
	NSString *affiliateParameters = [partnerId stringByAppendingString:affiliateToken];
	NSURL *newUrl = [url URLByAppendingQueryString:affiliateParameters];

	
	NSString *programID = [[Configuration sharedConfiguration] stringForIdentifier:@"social.tradedoubler-programID"];
	
	NSString *websiteID = [[Configuration sharedConfiguration] stringForIdentifier:@"social.tradedoubler-websiteID"];

	NSString *prefix = [NSString stringWithFormat:tradeDoublerPrefix, programID, websiteID];
	NSString *encodedUrl = [[newUrl absoluteString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	return [NSURL URLWithString:[prefix stringByAppendingString:encodedUrl]];
}

@end

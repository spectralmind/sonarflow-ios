#import "SFITunesHelper.h"
#import "SBJsonParser.h"

@interface SFITunesHelper ()
@property (nonatomic, strong) SBJsonParser *jsonParser;
@end

@implementation SFITunesHelper

@synthesize baseURL;
@synthesize jsonParser;
@synthesize searchInProgress;
@synthesize searchResults;
@synthesize searchError;

+ (NSString*)encodeURL:(NSString *)string {
    NSString *newString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
    
    if(newString == nil) {
		return @"";	// TODO: is this the right kind of error handling?!
    }
    
	return newString;
}


- (id)initWithBaseURL:(NSString *)theURL {
	self = [super init];
    if(self == nil) {
		return nil;
	}
	
	self.baseURL = theURL;
	SBJsonParser *theParser = [[SBJsonParser alloc] init];
	self.jsonParser = theParser;
	
	self.searchInProgress = YES;
	self.searchResults = nil;
	self.searchError = nil;
	
    return self;
}



#pragma mark -
#pragma mark - Parse JSON

- (NSDictionary *)parseJSON:(NSString *)input {
    NSDictionary *parsedObject = [self.jsonParser objectWithString:input];
    return parsedObject;
}

#pragma mark -
#pragma mark Helper Methods

- (void)executeRequest:(NSString *)apiMethodPath query:(NSString *)query {
    // Build URL
    NSString *path = [NSString pathWithComponents:[NSArray arrayWithObjects:self.baseURL, apiMethodPath, nil]];
    NSString *completeRequest = [NSString stringWithFormat:@"%@?%@", path, query];
    NSURL *requestURL = [NSURL URLWithString:completeRequest];
    
    // Create request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        // Nil first
        self.searchResults = nil;
        // Copy error
        self.searchError = error;
        
        if (error || !data) {
            self.searchResults = nil;
        }
        else {
            // Get response dictionary
            NSString* responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary *parsedObject = [self.jsonParser objectWithString:responseBody];
			
            // Check and assign search results
            if (parsedObject) {
                NSObject *resultCountObject = [parsedObject objectForKey:@"resultCount"];
                if (resultCountObject && [resultCountObject isKindOfClass:[NSNumber class]]) {
                    NSNumber *resultCount = (NSNumber *)resultCountObject;
                    if ([resultCount intValue] > 0) {
                        self.searchResults = [parsedObject objectForKey:@"results"];
                    }
                }
            }
        }
		
        // Search finished
        self.searchInProgress = NO;
	}];
}

@end

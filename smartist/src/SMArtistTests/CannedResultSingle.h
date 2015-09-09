#import "CannedResultAbstract.h"

#import "SMSingleArtistRequest.h"
#import "SMArtistResult.h"

@interface CannedResultSingle : CannedResultAbstract

@property (strong, readonly) SMSingleArtistRequest *request;

@property (strong, readonly) NSData *cannedResult;
@property (strong, readonly) NSError *error;
@property (strong, readonly) NSURLResponse *response;

+ (CannedResultSingle *)successfulCannedResultSingleWithRequest:(SMSingleArtistRequest *)theRequest canFilename:(NSString*)cannedName;

- (BOOL)responsibleForRequest:(NSURLRequest *)request;

@end

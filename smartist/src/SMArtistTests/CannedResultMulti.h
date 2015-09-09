#import "CannedResultAbstract.h"

#import "CannedResultSingle.h"
#import "SMArtistRequest.h"

@interface CannedResultMulti : CannedResultAbstract

@property (strong, readonly) NSArray *cannedResults;

+ (CannedResultMulti *)cannedResultMultiWithCannedResults:(NSArray *)cannedResults;

@end

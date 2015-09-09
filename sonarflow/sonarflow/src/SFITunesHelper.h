#import <Foundation/Foundation.h>

@interface SFITunesHelper : NSObject

- (id)initWithBaseURL:(NSString *)theURL;

@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, assign) BOOL searchInProgress;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) NSError *searchError;

- (void)executeRequest:(NSString *)apiMethodPath query:(NSString *)query; 

// URL Encoding workaround
+ (NSString*)encodeURL:(NSString *)string;

@end
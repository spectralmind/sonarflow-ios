//
//  SMArtist.m
//  SMArtist
//
//  Created by Fabian on 23.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//

#import "SMArtist.h"

#import "SMRequestable.h"

#import "SMRootFactory.h"

#import "SMResultCache.h"

#import "SMArtistMerger.h"


@interface SMArtist () <SMRequestableDelegate>
@property (nonatomic, strong) SMRootFactory *rootFactory;
@property (nonatomic, strong) NSMutableArray *outstandingRequests;
@end

@implementation SMArtist
{
@private
    SMRootFactory *rootFactory;
    NSObject<SMArtistDelegate> *__weak delegate;
    NSMutableArray *outstandingRequests;
	NSOperationQueue *requestQueue;
}

@synthesize rootFactory, outstandingRequests;
@synthesize delegate;

- (id)init
{
    return [self initWithAWIDelegate:nil withConfiguration:nil];
}

- (id)initWithAWIDelegate:(NSObject<SMArtistDelegate>*)theDelegate withConfiguration:(SMArtistConfiguration *)configuration
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.rootFactory = [[SMRootFactory alloc] initWithConfiguration:configuration];
        self.delegate = theDelegate;
        self.outstandingRequests = [NSMutableArray array];
		requestQueue = [[NSOperationQueue alloc] init];
    }
    
    return self;
}

+ (SMArtist *)smartistWithDelegate:(NSObject<SMArtistDelegate>*)delegate withConfiguration:(SMArtistConfiguration *)configuration
{
    SMArtist *smartist = [[SMArtist alloc] initWithAWIDelegate:delegate withConfiguration:configuration];
    return smartist;
}


- (SMArtistConfiguration *)configuration
{
	return self.rootFactory.configuration;
}

- (void)setConfiguration:(SMArtistConfiguration *)configuration
{
	self.rootFactory.configuration = configuration;
}


- (void)addAndStartRequestable:(SMRequestable *)requestable
{
	@synchronized(self) {
		[self.outstandingRequests addObject:requestable];
	}
	
	[requestQueue addOperationWithBlock:^{
		[requestable startRequest];
	}];
}


#pragma mark - Public Cache Methods

- (void)purgeCompleteCache
{
	[rootFactory.cache clear];
}

- (void)purgeExpiredCache
{
	[rootFactory.cache pruneExpired];
}


#pragma mark - Public Web Query Methods

- (void)getArtistBiosWithArtistName:(NSString *)artistName clientId:(id)clientId priority:(BOOL)priority {
	SMRequestable *requestable = [[self.rootFactory requestableFactory] artistBiosRequestableForArtistName:artistName withClientId:clientId delegate:self priority:priority];
	[self addAndStartRequestable:requestable];
}

- (void)getArtistSimilarityWithArtistName:(NSString *)artistName clientId:(id)clientId priority:(BOOL)priority {
	SMRequestable *requestable = [[self.rootFactory requestableFactory] artistSimilarityRequestableForArtistName:artistName withClientId:clientId delegate:self priority:priority];
	[self addAndStartRequestable:requestable];
}

- (void)getArtistSimilarityMatrixWithArtistNames:(NSArray *)artistNames clientId:(id)clientId priority:(BOOL)priority {
	SMRequestable *requestable = [[self.rootFactory requestableFactory] artistSimilarityMatrixRequestableForArtistNames:artistNames withClientId:clientId delegate:self priority:priority];
	[self addAndStartRequestable:requestable];
}

- (void)getArtistImagesWithArtistName:(NSString *)artistName clientId:(id)clientId priority:(BOOL)priority {
	SMRequestable *requestable = [[self.rootFactory requestableFactory] artistImagesRequestableForArtistName:artistName withClientId:clientId delegate:self priority:priority];
	[self addAndStartRequestable:requestable];
}

- (void)getArtistVideosWithArtistName:(NSString *)artistName clientId:(id)clientId priority:(BOOL)priority {
	SMRequestable *requestable = [[self.rootFactory requestableFactory] artistVideosRequestableForArtistName:artistName withClientId:clientId delegate:self priority:priority];
	[self addAndStartRequestable:requestable];
}

- (void)getArtistGenresWithArtistName:(NSString *)artistName clientId:(id)clientId priority:(BOOL)priority {
	SMRequestable *requestable = [[self.rootFactory requestableFactory] artistGenresRequestableForArtistName:artistName withClientId:clientId delegate:self priority:priority];
	[self addAndStartRequestable:requestable];
}


#pragma mark - Private Methods

- (void)removeFinishedRequestable:(SMRequestable *)requestable
{
	@synchronized(self) {
		[self.outstandingRequests removeObject:requestable];
	}
}


#pragma mark - Delegate Methods

- (void)doneSMRequestWithRequestable:(SMRequestable *)requestable withResult:(SMArtistResult *)theResult
{
	SEL protocolReturnMethod;
	
	if        ([theResult isKindOfClass:[SMArtistBiosResult class]]) {
		protocolReturnMethod = @selector(doneWebRequestWithArtistBiosResult:);
	} else if ([theResult isKindOfClass:[SMArtistImagesResult class]]) {
		protocolReturnMethod = @selector(doneWebRequestWithArtistImagesResult:);
	} else if ([theResult isKindOfClass:[SMArtistSimilarityResult class]]) {
		protocolReturnMethod = @selector(doneWebRequestWithArtistSimilarityResult:);
	} else if ([theResult isKindOfClass:[SMArtistSimilarityMatrixResult class]]) {
		protocolReturnMethod = @selector(doneWebRequestWithArtistSimilarityMatrixResult:);
	} else if ([theResult isKindOfClass:[SMArtistVideosResult class]]) {
		protocolReturnMethod = @selector(doneWebRequestWithArtistVideosResult:);
	} else if ([theResult isKindOfClass:[SMArtistGenresResult class]]) {
		protocolReturnMethod = @selector(doneWebRequestWithArtistGenresResult:);
	} else {
		NSAssert(NO, @"wrong result type encountered: %@", theResult);
	}
	
	if([self.delegate respondsToSelector:protocolReturnMethod]) {
		[self.delegate performSelectorOnMainThread:protocolReturnMethod withObject:theResult waitUntilDone:YES];
	}
	
    [self removeFinishedRequestable:requestable];
}


@end

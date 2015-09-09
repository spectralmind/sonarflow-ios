//
//  SMArtist.h
//  SMArtist
//
//  Created by Fabian on 23.08.11.
//  Copyright 2011 Spectralmind. All rights reserved.
//
// Public Interface for doing Artist-Related Web Service Requests
//

#import <Foundation/Foundation.h>

#import "SMArtistConfiguration.h"

#import "SMArtistBiosResult.h"
#import "SMArtistSimilarityResult.h"
#import "SMArtistSimilarityMatrixResult.h"
#import "SMArtistImagesResult.h"
#import "SMArtistVideosResult.h"
#import "SMArtistGenresResult.h"

@class SMRootFactory, SMMergerFactory;

@protocol SMArtistDelegate;

/*!
 @class SMArtist
 
 @abstract An SMArtist object provides highlevel methods to fetch artist-related data from various webservices.
 
 @discussion SMArtist completely abstracts from the webservices used in the background.
    One request can involve multiple calls to one or more webservices and local caching of queries.
    Results are returned asynchronously through the SMArtistDelegate protocol.
 */
@interface SMArtist : NSObject

/*! 
 @method smartistWithDelegate:
 @abstract Allocates and initializes a SMArtist with the given delegate.
 @param delegate The delegate which receives asynchronous results via the SMArtistDelegate protocol. 
 @param configuration The configuration which allows customization of SMArtist's behavior. 
 @result A newly-created and autoreleased SMArtist instance. 
 */
+ (SMArtist *)smartistWithDelegate:(NSObject<SMArtistDelegate>*)delegate withConfiguration:(SMArtistConfiguration *)configuration;

@property (nonatomic, weak) NSObject<SMArtistDelegate> *delegate;

@property (nonatomic, weak) SMArtistConfiguration *configuration;

/*!
 @method initWithAWIDelegate:
 @abstract Initializes a SMArtist with the given delegate.
 @param delegate The delegate which receives asynchronous results via the SMArtistDelegate protocol. 
 @param configuration The configuration which allows customization of SMArtist's behavior. 
 @result The initialized SMArtist instance. 
 */
- (id)initWithAWIDelegate:(NSObject<SMArtistDelegate>*)theDelegate withConfiguration:(SMArtistConfiguration *)configuration;


/*!
 @method purgeCompleteCache
 @abstract Deletes the whole cache.
 */
- (void)purgeCompleteCache;

/*!
 @method purgeExpiredCache
 @abstract Deletes the part of the cache which already is expired.
 @discussion The expiration time can be set via the configuration
 */
- (void)purgeExpiredCache;


/*!
 @method getArtistBiosWithArtistName:clientId:priority:
 @abstract Sends a request to get artist biographies for the specified artist.
    Results are returned asynchronously through the SMArtistDelegate protocol method doneWebRequestWithArtistBiosResult:
 @param artistName The name of the artist to search for biographies for.
 @param clientId Any client provided object which will be returned again in the asynchronous result.
 @param priority Indicates that the user expects the result as soon as possible 
 */
- (void)getArtistBiosWithArtistName:(NSString *)artistName clientId:(id)clientId priority:(BOOL)priority;

/*!
 @method getArtistSimilarityWithArtistName:clientId:priority:
 @abstract Sends a request to get similar artists to the specified artist.
 Results are returned asynchronously through the SMArtistDelegate protocol method doneWebRequestWithArtistSimilarityResult:
 @param artistName The name of the artist to search for similar artists to.
 @param clientId Any client provided object which will be returned again in the asynchronous result. 
 @param priority Indicates that the user expects the result as soon as possible
*/
- (void)getArtistSimilarityWithArtistName:(NSString *)artistName clientId:(id)clientId priority:(BOOL)priority;

/*!
 @method getArtistSimilarityMatrixWithArtistNames:clientId:priority:
 @abstract Sends a request to get a matrix with the similarities between the given artists.
 Results are returned asynchronously through the SMArtistDelegate protocol method doneWebRequestWithArtistSimilarityMatrixResult:
 @param artistNames An array with NSString objects containing the names of the artists.
 @param clientId Any client provided object which will be returned again in the asynchronous result. 
 @param priority Indicates that the user expects the result as soon as possible
*/
- (void)getArtistSimilarityMatrixWithArtistNames:(NSArray *)artistNames clientId:(id)clientId priority:(BOOL)priority;

/*!
 @method getArtistImagesWithArtistName:clientId:priority:
 @abstract Sends a request to get artist images for the specified artist.
 Results are returned asynchronously through the SMArtistDelegate protocol method doneWebRequestWithArtistImagesResult:
 @param artistName The name of the artist to search for images for.
 @param clientId Any client provided object which will be returned again in the asynchronous result. 
 @param priority Indicates that the user expects the result as soon as possible
 */
- (void)getArtistImagesWithArtistName:(NSString *)artistName clientId:(id)clientId priority:(BOOL)priority;

/*!
 @method getArtistVideosWithArtistName:clientId:priority:
 @abstract Sends a request to get artist videos for the specified artist.
 Results are returned asynchronously through the SMArtistDelegate protocol method doneWebRequestWithArtistVideosResult:
 @param artistName The name of the artist to search for videos for.
 @param clientId Any client provided object which will be returned again in the asynchronous result. 
 @param priority Indicates that the user expects the result as soon as possible
 */
- (void)getArtistVideosWithArtistName:(NSString *)artistName clientId:(id)clientId priority:(BOOL)priority;

- (void)getArtistGenresWithArtistName:(NSString *)artistName clientId:(id)clientId priority:(BOOL)priority;

@end


/*!
 @protocol SMArtistDelegate
 
 @abstract A SMArtistDelegate receives request results asynchronously by the given methods.
    The results are returned on the Main Thread.
    For each result type, there exists a delegate method.
 
 @discussion 
 
    doneWebRequestWithArtistBiosResult: is the answer to a call to one of the following methods:
        getArtistBiosWithArtistName:withClientId:
 
    doneWebRequestWithArtistSimilarityResult: is the answer to a call to one of the following methods:
        getArtistSimilarityWithArtistName:withClientId:
 
    doneWebRequestWithArtistSimilarityMatrixResult: is the answer to a call to one of the following methods:
	    getArtistSimilarityMatrixWithArtistNames:withClientId:
    
    doneWebRequestWithArtistImagesResult: is the answer to a call to one of the following methods:
        getArtistImagesWithArtistName:withClientId:
 */
@protocol SMArtistDelegate <NSObject>
@optional
- (void)doneWebRequestWithArtistBiosResult:(SMArtistBiosResult *)theResult;
- (void)doneWebRequestWithArtistSimilarityResult:(SMArtistSimilarityResult *)theResult;
- (void)doneWebRequestWithArtistSimilarityMatrixResult:(SMArtistSimilarityMatrixResult *)theResult;
- (void)doneWebRequestWithArtistImagesResult:(SMArtistImagesResult *)theResult;
- (void)doneWebRequestWithArtistVideosResult:(SMArtistVideosResult *)theResult;
- (void)doneWebRequestWithArtistGenresResult:(SMArtistGenresResult *)theResult;
//- (void)doneWebRequestWithArtistTagsResult:(ArtistWebInfoTagsResult *)theResult;
//- (void)doneWebRequestWithArtistEventsResult:(ArtistWebInfoEventsResult *)theResult;
//- (void)doneWebRequestWithArtistAudioResult:(ArtistWebInfoAudioResult *)theResult;
//- (void)doneWebRequestWithArtistUrlsResult:(ArtistWebInfoUrlsResult *)theResult;
//- (void)doneWebRequestWithArtistSearchResult:(ArtistWebInfoSearchResult *)theResult;
@end

#import "CannedResultSingle.h"

#import "SMArtistSimilarityResult.h"
#import "SMArtistBiosResult.h"
#import "SMArtistImagesResult.h"
#import "SMArtistVideosResult.h"
#import "SMArtistGenresResult.h"

#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>



@interface CannedResultSingleSimilarity : CannedResultSingle
@end
@interface CannedResultSingleBios : CannedResultSingle
@end
@interface CannedResultSingleImages : CannedResultSingle
@end
@interface CannedResultSingleVideos : CannedResultSingle
@end
@interface CannedResultSingleGenres : CannedResultSingle
@end



@implementation CannedResultSingle

@synthesize request;

@synthesize cannedResult;
@synthesize error;
@synthesize response;

+ (CannedResultSingle *)successfulCannedResultSingleWithRequest:(SMSingleArtistRequest *)theRequest canFilename:(NSString*)cannedName {
	switch (theRequest.type) {
		case SMSingleArtistRequestTypeArtistSimilarity:
			return [[CannedResultSingleSimilarity alloc] initSuccessfulResultWithRequest:theRequest canFilename:cannedName];
			
		case SMSingleArtistRequestTypeArtistBios:
			return [[CannedResultSingleBios alloc] initSuccessfulResultWithRequest:theRequest canFilename:cannedName];
			
		case SMSingleArtistRequestTypeArtistImages:
			return [[CannedResultSingleImages alloc] initSuccessfulResultWithRequest:theRequest canFilename:cannedName];
			
		case SMSingleArtistRequestTypeArtistVideos:
			return [[CannedResultSingleVideos alloc] initSuccessfulResultWithRequest:theRequest canFilename:cannedName];
			
		case SMSingleArtistRequestTypeArtistGenres:
			return [[CannedResultSingleGenres alloc] initSuccessfulResultWithRequest:theRequest canFilename:cannedName];
			
		default:
			NSAssert(NO, @"wrong SMSingleArtistRequest type specified: %i", theRequest.type);
			return nil;
	}
}


- (id)initSuccessfulResultWithRequest:(SMSingleArtistRequest *)theRequest canFilename:(NSString*)cannedName {
	self = [super init];
	if (self) {
		cannedResult = [[NSData alloc] initWithContentsOfFile:
						[[NSBundle bundleForClass:[self class]]
						 pathForResource:cannedName ofType:@"json"]];
		STAssertNotNil(cannedResult, @"Failed to load canned result '%@'", cannedName);
		
		[self initCommonWithRequest:theRequest urlResponseStatusCode:200];
	}
	return self;
}

- (id)initErrorResultWithRequest:(SMSingleArtistRequest *)theRequest error:(NSError *)theError urlResponseStatusCode:(NSInteger)theStatusCode {
	self = [super init];
	if (self) {
		error = theError;
		
		[self initCommonWithRequest:theRequest urlResponseStatusCode:theStatusCode];
	}
	return self;
}

- (void)initCommonWithRequest:(SMSingleArtistRequest *)theRequest urlResponseStatusCode:(NSInteger)theStatusCode {
	request = theRequest;
	response = [self getResponseWithStatusCode:theStatusCode];
}

- (NSURLResponse *)getResponseWithStatusCode:(NSInteger)statusCode
{
    id mockresponse = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[mockresponse stub] andReturnValue:OCMOCK_VALUE(statusCode)] statusCode];
    return mockresponse;
}



- (void)returnCannedResultForRequest:(NSURLRequest *)urlRequest forDelegate:(id<NSURLConnectionDelegate, NSURLConnectionDataDelegate>)delegate {
    assertThat(urlRequest, notNilValue());
    assertThat(delegate, notNilValue());
    
    if(cannedResult) {
        //NSLog(@"cannedResult");
        [delegate connection:nil didReceiveResponse:response];
        [delegate connection:nil didReceiveData:cannedResult];
        [delegate connectionDidFinishLoading:nil];
    }
    else if(error) {
        [delegate connection:nil didFailWithError:error];
    } else {
        STFail(@"Neither cannedResult nor error present");
    }
}

- (BOOL)checkOk:(SMArtistResult *)result {
	assertThat(result, notNilValue());
	
	assertThat(result.clientId, equalTo(request.clientId));
	assertThat(result.error, nilValue());
	
	//assertThat(theResult.request, notNilValue()); // TODO check more request properties, FIXME request generation in library
	
	return YES;
}


- (BOOL)responsibleForRequest:(NSURLRequest *)theRequest {
	/*
     STAssertEqualObjects([url scheme], @"http", @"Invalid request scheme");
     STAssertEqualObjects([url host], @"api.geonames.org", @"Invalid request host");
     STAssertEqualObjects([url path], @"/findNearbyJSON", @"Invalid request path");
     NSArray *params = [[url query] componentsSeparatedByString:@"&"];
     STAssertTrue([params containsObject:@"username=unittest"], @"Username not set correctly in request");
     */
	
	SMArtistConfiguration *defaultConfig = [SMArtistConfiguration defaultConfiguration];
    if ([[theRequest.URL host] isEqualToString:[[NSURL URLWithString:defaultConfig.lastfmUrl] host]]  && request.servicesMask == SMArtistWebServicesLastfm) {
        return YES;
	}
	else if ([[theRequest.URL host] isEqualToString:[[NSURL URLWithString:defaultConfig.echonestUrl] host]]  && request.servicesMask == SMArtistWebServicesEchonest) {
		return YES;
	}
	else if ([[theRequest.URL host] isEqualToString:[[NSURL URLWithString:defaultConfig.youtubeUrl] host]]  && request.servicesMask == SMArtistWebServicesYoutube) {
		return YES;
	}
	else {
		return NO;
	}
}

@end


@implementation CannedResultSingleSimilarity

- (BOOL)checkOk:(SMArtistSimilarityResult *)result {
	[super checkOk:result];
	
	assertThat(result.similarArtists, notNilValue());
	
	assertThatInteger([result.similarArtists count], greaterThan([NSNumber numberWithInt:0]));
	
	for (SMSimilarArtist *artist in result.similarArtists) {
		assertThat(artist, instanceOf([SMSimilarArtist class]));
		assertThat(artist.artistName, notNilValue());
		assertThat(artist.artistName, isNot(equalToIgnoringWhiteSpace(@"")));
		assertThatFloat(artist.matchValue, greaterThanOrEqualTo([NSNumber numberWithFloat:0]));
		assertThatFloat(artist.matchValue, lessThanOrEqualTo([NSNumber numberWithFloat:1]));
	}
	
	// always returning yes as doing asserts above
	return YES;
}

@end


@implementation CannedResultSingleBios

- (BOOL)checkOk:(SMArtistBiosResult *)result {
	[super checkOk:result];
	
    assertThat(result.bios, notNilValue());
    
    assertThatInteger([result.bios count], greaterThan([NSNumber numberWithInt:0]));
    
    for (SMArtistBio *bio in result.bios) {
        assertThat(bio, instanceOf([SMArtistBio class]));
        assertThat(bio.url, notNilValue());
        assertThat(bio.url, isNot(equalToIgnoringWhiteSpace(@""))); // TODO check for valid url
        //assertThat(bio.sourceName, allOf(notNilValue(), isNot(equalToIgnoringWhiteSpace(@"")))); // some problem with allOf
        assertThat(bio.sourceName, notNilValue());
        assertThat(bio.sourceName, isNot(equalToIgnoringWhiteSpace(@"")));
        //assertThat(bio.previewText, allOf(notNilValue(), isNot(equalToIgnoringWhiteSpace(@""))));
        assertThat(bio.previewText, notNilValue());
        assertThat(bio.previewText, isNot(equalToIgnoringWhiteSpace(@"")));
        //assertThat(bio.fulltext, allOf(notNilValue(), isNot(equalToIgnoringWhiteSpace(@"")))); // fulltext might be nil
    }
    
    // always returning yes as doing asserts above
    return YES;
}

@end


@implementation CannedResultSingleImages

- (BOOL)checkOk:(SMArtistImagesResult *)result {
	[super checkOk:result];
	
    assertThat(result.images, notNilValue());
    
    assertThatInteger([result.images count], greaterThan([NSNumber numberWithInt:0]));
    
    for (SMArtistImage *image in result.images) {
        assertThat(image, instanceOf([SMArtistImage class]));
        assertThat(image.imageUrl, notNilValue());
        assertThat(image.imageUrl, isNot(equalToIgnoringWhiteSpace(@""))); // TODO check for valid url
        //assertThat(image.imageSize, notNilValue()); // can be nil
        CGSize imageSize = [image.imageSize CGSizeValue];
        assertThatFloat(imageSize.width, greaterThanOrEqualTo([NSNumber numberWithFloat:0])); // may fail for echonest
        assertThatFloat(imageSize.height, greaterThanOrEqualTo([NSNumber numberWithFloat:0]));
    }
    
    // always returning yes as doing asserts above
    return YES;
}

@end


@implementation CannedResultSingleVideos

- (BOOL)checkOk:(SMArtistVideosResult *)result {
	[super checkOk:result];
	
    assertThat(result.videos, notNilValue());
    
    assertThatInteger([result.videos count], greaterThan([NSNumber numberWithInt:0]));
    
    for (SMArtistVideo *video in result.videos) {
        assertThat(video, instanceOf([SMArtistVideo class]));
        assertThat(video.title, notNilValue());
        assertThat(video.title, isNot(equalToIgnoringWhiteSpace(@"")));
        assertThat(video.videoUrl, notNilValue());
        assertThat(video.videoUrl, isNot(equalToIgnoringWhiteSpace(@""))); // TODO check for valid url
    }
    
    // always returning yes as doing asserts above
    return YES;
}

@end


@implementation CannedResultSingleGenres

- (BOOL)checkOk:(SMArtistGenresResult *)result {
	[super checkOk:result];
	
    assertThat(result.genres, notNilValue());
    
    assertThatInteger([result.genres count], greaterThan([NSNumber numberWithInt:0]));
    
	STFail(@"Not yet an SMArtistGenre object");
	
	/*
    for (SMArtistGenre *genre in result.genres) {
        assertThat(genre, instanceOf([SMArtistGenre class]));
        assertThat(genre.genreUrl, notNilValue());
        assertThat(genre.genreUrl, isNot(equalToIgnoringWhiteSpace(@"")));
    }
	 */
    
    // always returning yes as doing asserts above
    return YES;
}

@end


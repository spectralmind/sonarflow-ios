//
//  SMSingleArtistRequest.h
//  SMArtist
//
//  Created by Raphael Charwot on 15.02.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "SMArtistRequest.h"

enum SMSingleArtistRequestType {
	SMSingleArtistRequestTypeArtistSimilarity,
    SMSingleArtistRequestTypeArtistBios,
    SMSingleArtistRequestTypeArtistImages,
    SMSingleArtistRequestTypeArtistVideos,
	SMSingleArtistRequestTypeArtistGenres
};
typedef enum SMSingleArtistRequestType SMSingleArtistRequestType;

@interface SMSingleArtistRequest : SMArtistRequest

@property (strong, nonatomic, readonly) NSString *artistName;
@property (nonatomic, assign) SMSingleArtistRequestType type;

- (id)initWithArtistName:(NSString *)theArtistName requestType:(SMSingleArtistRequestType)theType
				clientId:(id)theClientId servicesMask:(SMArtistWebServices)theServicesMask
		   configFactory:(SMRootFactory *)theConfigFactory;

@end

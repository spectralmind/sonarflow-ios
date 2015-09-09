//
//  SMArtistSimilarityMatrixRequest.h
//  SMArtist
//
//  Created by Raphael Charwot on 15.02.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "SMArtistRequest.h"

@interface SMArtistSimilarityMatrixRequest : SMArtistRequest

- (id)initWithArtistNames:(NSArray *)theArtistNames clientId:(id)theClientId
				 services:(SMArtistWebServices)theServicesMask
			configFactory:(SMRootFactory *)theConfigFactory;

@end

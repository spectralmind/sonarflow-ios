//
//  SMWebInfoFactory.m
//  SMArtist
//
//  Created by Fabian on 06.09.11.
//  Copyright (c) 2011 Spectralmind. All rights reserved.
//

#import "SMWebInfoFactory.h"

#import "SMRootFactory.h"
#import "SMSingleArtistRequest.h"

@implementation SMWebInfoFactory
{
    SMRootFactory *__weak rootFactory;
}

@synthesize rootFactory;

// TODO this method definitely needs cleanup
- (NSArray *)webInfosWithDelegate:(id<SMRequestableDelegate>)delegate forRequest:(SMSingleArtistRequest *)request
{
	NSMutableArray *webinfos = [NSMutableArray array];
	
	SMArtistWebServices requesttypeServicesMask = request.servicesMask;
	SMArtistWebServices allSMArtistWebServices[] = {SMArtistWebServicesLastfm, SMArtistWebServicesEchonest, SMArtistWebServicesYoutube};
	
	for (int i = 0; i < 3; i++) {
		SMArtistWebServices webservice = allSMArtistWebServices[i];
		if ((requesttypeServicesMask & webservice)) {
			SMArtistWebInfo *webinfo = [SMArtistWebInfo webinfoWithConfiguration:self.rootFactory withDelegate:delegate ForWebservice:webservice forRequestType:request.type];
			if (webinfo != nil) {
				webinfo.request = request;
				[webinfos addObject:webinfo];
			}

		}
	}

	return webinfos;
}

@end

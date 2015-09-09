//
//  ArtistInfoViewController+Private.h
//  sonarflow
//
//  Created by Fabian on 17.01.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "ArtistInfoViewController.h"

@interface ArtistInfoViewController (Private)

@property (nonatomic, strong) NSString *biographyText;
@property (nonatomic, strong) NSString *biographyURL;
@property (nonatomic, strong) NSArray *artistImages;
@property (nonatomic, strong) NSArray *artistVideos;

@property (nonatomic, strong) NSString *noBio;
@property (nonatomic, strong) NSString *noImages;
@property (nonatomic, strong) NSString *noVideos;

- (void)postStopYoutubePlaybackNotification;

@end

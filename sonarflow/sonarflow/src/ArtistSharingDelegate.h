//
//  ArtistInfoSharingDelegate.h
//  sonarflow
//
//  Created by Arvid Staub on 07.06.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ArtistSharingDelegate <NSObject>
@optional
- (void)shareArtist:(NSString *)artistName fromButton:(UIView *)sender;
- (void)shareArtistOnTwitter:(NSString *)artistName;
- (void)shareArtistOnFacebook:(NSString *)artistName;
@end
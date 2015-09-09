//
//  SFSpotifyToplistBridge.m
//  sonarflow
//
//  Created by Arvid Staub on 25.06.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "SFSpotifyToplistBridge.h"

#import "NSArray+NSNull.h"
#import "SFSpotifyChildrenFactory.h"
#import "SFSpotifyPlayer.h"
#import "SPToplist.h"
#import "SFSpotifyToplist.h"

@implementation SFSpotifyToplistBridge {
	SFSpotifyChildrenFactory *childrenFactory;
	SPToplist *toplist;
	
	SFSpotifyToplist *mediaItem;
	
	BOOL hasAddedMediaItem;
}

- (id)initWithToplist:(SPToplist *)theToplist name:(NSString *)theName origin:(CGPoint)theOrigin color:(UIColor *)theColor key:(id)theKey spotifyPlayer:(SFSpotifyPlayer *)theSpotifyPlayer factory:(SFSpotifyChildrenFactory *)theChildrenFactory {
    if(self == nil) {
		return nil;
	}
	
	mediaItem = [[SFSpotifyToplist alloc] initWithName:theName origin:theOrigin color:theColor key:theKey spotifyPlayer:theSpotifyPlayer];
	if(mediaItem == nil) {
		return nil;
	}
	
	toplist = theToplist;
	childrenFactory = theChildrenFactory;
	
	[self startObserving];
	[self loadCoversAndCreateChildrenFromTracks];
	
    return self;
}

- (id)init {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (void)dealloc {
	[self endObserving];
}

- (void)startObserving {
	[toplist addObserver:self forKeyPath:@"tracks" options:0 context:nil];	
}

- (void)endObserving {
	[toplist removeObserver:self forKeyPath:@"tracks"];	
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	NSLog(@"change to %@", keyPath);
    if([keyPath isEqualToString:@"tracks"] == NO) {
		return;
	}
	
	[self loadCoversAndCreateChildrenFromTracks];
}

#define kMaxTopTracksIPhone	30
#define kMaxTopTracksIPad	50

- (void)loadCoversAndCreateChildrenFromTracks {
	if(toplist.tracks == nil) {
		return;
	}
	
	NSUInteger maxTopTracks;
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		maxTopTracks = kMaxTopTracksIPad;
	} 
	else {
		maxTopTracks = kMaxTopTracksIPhone;
	}
	
	maxTopTracks = MIN(maxTopTracks, toplist.tracks.count);
	NSArray *limitedToptracks = [toplist.tracks subarrayWithRange:NSMakeRange(0, maxTopTracks)];
	
	[SPAsyncLoading waitUntilLoaded:limitedToptracks timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *toptracks, NSArray *notLoaded) {
		NSArray *covers = [[toptracks valueForKeyPath:@"album.cover"] arrayWithoutNSNullObjects];
		[SPAsyncLoading waitUntilLoaded:covers timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedCovers, NSArray *notLoaded) {
			mediaItem.children = [childrenFactory childrenFromSPTracks:toptracks];
			[self notifyDelegateWithMediaItem:mediaItem];
		}];	
	}];
}

@end

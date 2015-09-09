//
//  SMViewController.m
//  MediaPlayerDiagnostics
//
//  Created by Raphael Charwot on 04.04.12.
//  Copyright (c) 2012 Charwot. All rights reserved.
//

#import "SMViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface SMViewController ()

@property (nonatomic, readonly) MPMusicPlayerController *player;
@property (nonatomic, strong) NSArray *songs;

@end

@implementation SMViewController {
	
}

@synthesize songs;

- (MPMusicPlayerController *)player {
	return [MPMusicPlayerController iPodMusicPlayer];
}

- (void)viewDidLoad {
    [super viewDidLoad];

	MPMediaQuery *allTracksQuery = [MPMediaQuery songsQuery];
	NSArray *allSongs = [allTracksQuery items];
	NSUInteger numSongs = MIN([allSongs count], 10);
	self.songs = [allSongs subarrayWithRange:NSMakeRange(0, numSongs)];
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self
						   selector:@selector(nowPlayingItemChanged:)
							   name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
							 object:self.player];
	
	[notificationCenter addObserver:self
						   selector:@selector(playbackStateChanged:)
							   name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
							 object:self.player];
	[self.player beginGeneratingPlaybackNotifications];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

- (void)nowPlayingItemChanged:(NSNotification *)notification {
	NSLog(@"NowPlaying item changed: %@", notification);
	[self performSelectorOnMainThread:@selector(logItem) withObject:nil waitUntilDone:NO];
}

- (void)logItem {
	NSLog(@"Item: %@", self.player.nowPlayingItem);
}

- (void)playbackStateChanged:(NSNotification *)notification {
	NSLog(@"Playback state changed: %@", notification);
}

- (IBAction)play:(id)sender {
	NSLog(@"Play");
	[self reverseSongs];
	
	MPMediaItemCollection *itemCollection = [[MPMediaItemCollection alloc] initWithItems:self.songs];
	[self.player setQueueWithItemCollection:itemCollection];
	[self.player play];
	self.player.nowPlayingItem = [self.songs lastObject];
}

- (void)reverseSongs {
	NSMutableArray *reversed = [NSMutableArray arrayWithCapacity:self.songs.count];
	NSEnumerator *enumerator = [self.songs reverseObjectEnumerator];
    for(id element in enumerator) {
        [reversed addObject:element];
    }
	self.songs = reversed;
}

@end

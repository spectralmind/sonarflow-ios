#import "SFUserPlaylistsSection.h"

#import "SFArrayObserver.h"
#import "SFMediaLibrary.h"
#import "SFPlaylist.h"
#import "SFPlaylistsViewDelegate.h"

@interface SFUserPlaylistsSection () <SFArrayObserverDelegate>

@property (nonatomic, strong) NSMutableArray *playlists;

@end


@implementation SFUserPlaylistsSection {
	@private
	NSObject<SFMediaLibrary> *library;
	SFArrayObserver *playlistsObserver;
}

+ (NSString *)defaultTitle {
	return NSLocalizedString(@"Your Playlists", @"Title for list of user playlists");
}

- (id)init {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)initWithLibrary:(NSObject<SFMediaLibrary> *)theLibrary {
	self = [super init];
	if(self) {
		library = theLibrary;
		playlists = [library.playlists mutableCopy];
		playlistsObserver = [[SFArrayObserver alloc] initWithObject:library keyPath:@"playlists" delegate:self];
	}
	return self;
} 


@synthesize playlists;

- (NSUInteger)numberOfRows {
	return [self.playlists count];
}

- (NSObject<SFPlaylist> *)playlistForRow:(NSUInteger)row {
	return [self.playlists objectAtIndex:row];
}

- (BOOL)canEditRow:(NSUInteger)row {
	return YES;
}

- (void)deleteRow:(NSUInteger)row {
	NSObject<SFPlaylist> *playlist = [self playlistForRow:row];
	[playlist deleteList];
}

- (void)moveRowAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex {
	NSObject<SFPlaylist> *playlist = [self.playlists objectAtIndex:fromIndex];
	[self.playlists removeObjectAtIndex:fromIndex];
	[self.playlists insertObject:playlist atIndex:toIndex];
	
	[self updatePlaylistOrder];
}

- (void)updatePlaylistOrder {
	NSUInteger index = 0;
	for(NSObject<SFPlaylist> *playlist in self.playlists) {
		[playlist setOrder:[NSNumber numberWithInteger:index]];
		++index;
	}
}

#pragma mark - SFArrayObserverDelegate

- (void)object:(NSObject *)object wasSetFrom:(id)oldValue to:(id)newValue {
	self.playlists = [library.playlists mutableCopy];
	[self.delegate reloadAllRowsOfSection:self];
}

- (void)objects:(NSArray *)objects wereDeletedAtIndexes:(NSIndexSet *)indexes ofObject:(NSObject *)object {
	[self handleDeletedPlaylists:objects];
}

- (void)objects:(NSArray *)oldObjects wereReplacedWithObjects:(NSArray *)newObjects atIndexes:(NSIndexSet *)indexes ofObject:(NSObject *)object {
	[self handleDeletedPlaylists:oldObjects];
	[self handleInsertedPlaylists:newObjects];
}

- (void)objects:(NSArray *)objects wereInsertedAtIndexes:(NSIndexSet *)indexes ofObject:(NSObject *)object {
	[self handleInsertedPlaylists:objects];
}

- (void)handleDeletedPlaylists:(NSArray *)deletedPlaylists {
	if([deletedPlaylists count] == 0) {
		return;
	}
	
	NSIndexSet *indexes = [self indexesForPlaylists:deletedPlaylists];
	for(NSObject<SFPlaylist> *playlist in deletedPlaylists) {
		[self.playlists removeObject:playlist];
	}
	[self updatePlaylistOrder];
	[self.delegate removeRows:indexes fromSection:self];
}

- (void)handleInsertedPlaylists:(NSArray *)insertedPlaylists {
	if([insertedPlaylists count] == 0) {
		return;
	}
	
	for(NSObject<SFPlaylist> *playlist in insertedPlaylists) {
		NSUInteger index = [self indexForPlaylistOrder:[playlist order]];
		[self.playlists insertObject:playlist atIndex:index];
	}
	
	NSIndexSet *indexes = [self indexesForPlaylists:insertedPlaylists];
	[self.delegate insertRows:indexes intoSection:self];
}

- (NSIndexSet *)indexesForPlaylists:(NSArray *)thePlaylists {
	NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
	for(NSObject<SFPlaylist> *playlist in thePlaylists) {
		NSUInteger index = [self.playlists indexOfObject:playlist];
		if(index != NSNotFound) {
			[indexes addIndex:index];
		}
	}
	
	return indexes;
}

- (NSUInteger)indexForPlaylistOrder:(NSNumber *)order {
	int index = 0;
	for(NSObject<SFPlaylist> *playlist in self.playlists) {
		if([[playlist order] compare:order] != NSOrderedAscending) {
			break;
		}
		++index;
	}
	
	return index;
}

@end

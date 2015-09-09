#import "LastfmSettingsStorage.h"
#import "NSFileManager+DocumentPath.h"

static NSString *kSettingsFilename =  @"lastfm.settings";

@implementation LastfmSettingsStorage {
	@private
	NSString *filePath;
}

- (id)init {
    self = [super init];
    if (self) {
		filePath = [NSFileManager pathForDocumentFile:kSettingsFilename];
    }
    return self;
}


- (LastfmSettings *)loadSettings {
	NSLog(@"reading settings object from file: %@\n", filePath);
	LastfmSettings *result = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
	return result;
}

- (void)storeSettings:(LastfmSettings *)settings {
	NSLog(@"writing settings object to file: %@\n", filePath);
	BOOL success = [NSKeyedArchiver archiveRootObject:settings toFile:filePath];
	if(success) {
		NSLog(@"OK\n");
	}
	else {
		NSLog(@"cannot write!\n");
	}
}

@end
